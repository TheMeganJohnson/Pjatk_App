import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/io_client.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_certificate_pinning/http_certificate_pinning.dart'
    show HttpCertificatePinning, SHA;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'home_page.dart';
import 'globals.dart' as globals;
import 'main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pin_setup.dart';
import 'pin_entry.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final String _errorMessage = '';
  late Map<String, String> texts;

  final List<String> _serverUrls = [
    'https://ck.pjwstk.edu.pl/cyfrowe_klucze_app/login-userm/',
    'https://194.92.77.100:50343/cyfrowe_klucze_app/login-userm/',
  ];

  final List<String> _sha256Pins = [
    'fae88b1008028296cb00f16185f51cc2bc8ccb1ebe12f6763844eaa688fd6476',
    '4d71cf514624474d6e6bf7059ea8fd7b9c85b32b21cca5dd2c2aee592968fe96',
  ];

  @override
  void initState() {
    super.initState();
    _updateTexts();
    globals.languageNotifier.addListener(_onLanguageChange);
    _checkForPin();
  }

  Future<void> _checkForPin() async {
    final prefs = await SharedPreferences.getInstance();
    final pin = prefs.getString('user_pin');
    if (pin != null && pin.isNotEmpty) {
      // Show PIN entry dialog/page instead of login
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PinEntryPage()),
      );
      if (result == true) {
        // PIN correct, now check session key with server
        final serverUrl = await _getWorkingServerUrl();
        if (serverUrl == null) {
          _showErrorDialog(
            context,
            'No trusted server found or certificate mismatch.',
          );
          return;
        }

        try {
          final client = await createTrustedClient();
          // Make a GET request to the same /login-userm/ endpoint
          final response = await client.get(Uri.parse(serverUrl));

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final serverSessionKey = data['session_key'];
            // Get the saved session key (from globals or prefs)
            final localSessionKey =
                prefs.getString('user_sessionKey') ?? globals.globalSessionKey;

            if (serverSessionKey == localSessionKey &&
                serverSessionKey != null &&
                serverSessionKey.isNotEmpty) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            } else {
              _showErrorDialog(
                context,
                'Session key mismatch. Please log in again.',
              );
            }
          } else {
            _showErrorDialog(context, 'Failed to verify session key.');
          }
        } catch (e) {
          _showErrorDialog(context, 'Error: $e');
        }
      }
    }
  }

  @override
  void dispose() {
    // Remove the listener when the widget is disposed
    globals.languageNotifier.removeListener(_onLanguageChange);
    super.dispose();
  }

  void _onLanguageChange() {
    setState(() {
      // Update texts when the language changes
      _updateTexts();
    });
  }

  void _updateTexts() {
    // Define translated texts for both languages
    final Map<String, String> polishTexts = {
      'email': 'Nazwa Użytkownika',
      'password': 'Hasło',
      'login': 'Zaloguj',
      'invalidEmailOrLogin': 'Podaj poprawny email lub login.',
      'invalidCredentials': 'Złe hasło lub email. Spróbuj ponownie.',
      'error': 'Błąd',
      'ok': 'OK',
    };

    final Map<String, String> englishTexts = {
      'email': 'Username',
      'password': 'Password',
      'login': 'Log In',
      'invalidEmailOrLogin': 'Enter a valid email or login.',
      'invalidCredentials': 'Invalid email or password. Try again.',
      'error': 'Error',
      'ok': 'OK',
    };

    // Choose the appropriate texts based on the global language setting
    texts = globals.globalLanguagePolish == true ? polishTexts : englishTexts;
  }

  Future<String?> _getWorkingServerUrl() async {
    for (final url in _serverUrls) {
      try {
        final uri = Uri.parse(url);
        final host = uri.host;
        final result = await HttpCertificatePinning.check(
          serverURL: uri.origin,
          headerHttp: {},
          sha: SHA.SHA256,
          allowedSHAFingerprints: _sha256Pins,
          timeout: 5,
        );
        print('Pinning result for $host: $result');
        if (result == "CONNECTION_SECURE") {
          return url;
        }
      } catch (e) {
        print('Error checking server $url: $e');
      }
    }
    return null;
  }

  Future<void> _login(BuildContext context) async {
    String username = emailController.text.trim();
    String password = passwordController.text;

    if (!_isValidEmail(username) && !_isValidLogin(username)) {
      _showErrorDialog(context, texts['invalidEmailOrLogin']!);
      return;
    }

    final serverUrl = await _getWorkingServerUrl();
    if (serverUrl == null) {
      _showErrorDialog(
        context,
        'No trusted server found or certificate mismatch.',
      );
      return;
    }

    try {
      final client = await createTrustedClient();
      final response = await client.post(
        Uri.parse(serverUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          globals.globalSessionKey = data['session_key'];
          globals.globalFullName = username;
          globals.globalUserType = 'Admin';
          globals.globalEmail = '$username@pjwstk.edu.pl';
          globals.globalGroup = 'GIs I.7';

          // Save to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_fullName', globals.globalFullName ?? '');
          await prefs.setString('user_userType', globals.globalUserType ?? '');
          await prefs.setString('user_email', globals.globalEmail ?? '');
          await prefs.setString('user_group', globals.globalGroup ?? '');
          await prefs.setString(
            'user_sessionKey',
            globals.globalSessionKey ?? '',
          );

          await _fetchReservationsForToday();

          final isFirstLogin = !(prefs.getBool('has_logged_in') ?? false);

          if (isFirstLogin) {
            await prefs.setBool('has_logged_in', true);
            // Navigate to PIN setup
            final pinSet = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PinSetupPage()),
            );
            if (pinSet == true) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            }
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          }
        } else {
          _showErrorDialog(context, data['message']);
        }
      } else {
        _showErrorDialog(context, texts['invalidCredentials']!);
      }
    } catch (e) {
      _showErrorDialog(context, 'Error: $e');
    }
  }

  Future<void> _fetchReservationsForToday() async {
    final response = await http.post(
      Uri.parse('http://${globals.pcIP}/api/list_reservations/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'group': globals.globalGroup ?? '',
        'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        globals.globalReservations = data['reservations'];
      } else {
        print('Failed to fetch reservations: ${data['message']}');
      }
    } else {
      print('Failed to fetch reservations: ${response.reasonPhrase}');
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  bool _isValidLogin(String login) {
    return login.isNotEmpty;
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(texts['error']!),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text(texts['ok']!),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<IOClient> createTrustedClient() async {
    final context = SecurityContext(withTrustedRoots: true);

    // Load the certificate from assets
    final certBytes = await rootBundle.load(
      'assets/certs/ck.pjwstk.edu.pl.crt',
    );
    context.setTrustedCertificatesBytes(certBytes.buffer.asUint8List());

    final httpClient = HttpClient(context: context);
    return IOClient(httpClient);
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Login',
      showLeftButton: false, // Hide the "Home" button
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 300,
                child: TextField(
                  controller: emailController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: texts['email'],
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: passwordController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: texts['password'],
                  ),
                  obscureText: true,
                ),
              ),
              SizedBox(height: 16.0),
              SizedBox(
                width: 110,
                child: ElevatedButton(
                  onPressed: () => _login(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFED1C24),
                  ),
                  child: Text(
                    texts['login']!,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

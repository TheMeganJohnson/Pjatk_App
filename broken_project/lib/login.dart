import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'network.dart';
import 'home_page.dart';
import 'globals.dart' as globals;
import 'main.dart';
import 'pin_setup.dart';
import 'pin_entry.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController loginController = TextEditingController();
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
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PinEntryPage()),
      );
      if (result == true) {
        final serverUrl = await _getWorkingServerUrl();
        if (serverUrl == null) {
          _showErrorDialog(context, texts['noTrustedServer']!);
          return;
        }

        try {
          final dio = await NetworkHelper.getDio();
          final response = await dio.get(serverUrl);

          if (response.statusCode == 200) {
            final data =
                response.data is String
                    ? jsonDecode(response.data)
                    : response.data;
            final serverSessionKey = data['session_key'];
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
              // Remove PIN and session key, force re-login and PIN setup
              await prefs.remove('user_pin');
              await prefs.remove('user_sessionKey');
              _showErrorDialog(context, texts['sessionKeyMismatch']!);
            }
          } else {
            _showErrorDialog(context, texts['failedVerifySession']!);
          }
        } catch (e) {
          _showErrorDialog(context, '${texts['error']!}: $e');
        }
      }
    }
  }

  @override
  void dispose() {
    globals.languageNotifier.removeListener(_onLanguageChange);
    super.dispose();
  }

  void _onLanguageChange() {
    setState(() {
      _updateTexts();
    });
  }

  void _updateTexts() {
    final Map<String, String> polishTexts = {
      'login': 'Login',
      'password': 'Hasło',
      'loginButton': 'Zaloguj',
      'invalidLogin': 'Podaj poprawny login.',
      'invalidCredentials': 'Zły login lub hasło. Spróbuj ponownie.',
      'error': 'Błąd',
      'ok': 'OK',
      'noTrustedServer':
          'Nie znaleziono zaufanego serwera lub błąd certyfikatu.',
      'sessionKeyMismatch':
          'Klucz sesji nie pasuje. Zaloguj się ponownie i ustaw nowy PIN.',
      'failedVerifySession': 'Nie udało się zweryfikować klucza sesji.',
    };

    final Map<String, String> englishTexts = {
      'login': 'Login',
      'password': 'Password',
      'loginButton': 'Log In',
      'invalidLogin': 'Enter a valid login.',
      'invalidCredentials': 'Invalid login or password. Try again.',
      'error': 'Error',
      'ok': 'OK',
      'noTrustedServer': 'No trusted server found or certificate mismatch.',
      'sessionKeyMismatch':
          'Session key mismatch. Please log in again and set a new PIN.',
      'failedVerifySession': 'Failed to verify session key.',
    };

    texts = globals.globalLanguagePolish == true ? polishTexts : englishTexts;
  }

  Future<String?> _getWorkingServerUrl() async {
    for (final url in _serverUrls) {
      try {
        final dio = await NetworkHelper.getDio(sha256Pins: _sha256Pins);
        final response = await dio.head(url).catchError((_) => null);
        if (response != null && response.statusCode == 200) {
          return url;
        }
      } catch (e) {}
    }
    return null;
  }

  Future<void> _login(BuildContext context) async {
    String login = loginController.text.trim();
    String password = passwordController.text;

    if (!_isValidLogin(login)) {
      _showErrorDialog(context, texts['invalidLogin']!);
      return;
    }

    final serverUrl = await _getWorkingServerUrl();
    if (serverUrl == null) {
      _showErrorDialog(context, texts['noTrustedServer']!);
      return;
    }

    try {
      final dio = await NetworkHelper.getDio();
      final response = await dio.post(
        serverUrl,
        data: {'username': login, 'password': password},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        final data =
            response.data is String ? jsonDecode(response.data) : response.data;
        if (data['status'] == 'success') {
          globals.globalSessionKey = data['session_key'];

          globals.globalFullName = login;
          globals.globalUserType = 'Admin';
          globals.globalEmail = ''; // Not used anymore
          globals.globalGroup = 'GIs I.7';

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_fullName', globals.globalFullName ?? '');
          await prefs.setString('user_userType', globals.globalUserType ?? '');
          await prefs.setString('user_group', globals.globalGroup ?? '');
          await prefs.setString(
            'user_sessionKey',
            globals.globalSessionKey ?? '',
          );

          await _fetchReservationsForToday();

          final isFirstLogin = !(prefs.getBool('has_logged_in') ?? false);

          if (isFirstLogin) {
            await prefs.setBool('has_logged_in', true);
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
          _showErrorDialog(context, texts['invalidCredentials']!);
        }
      } else {
        _showErrorDialog(context, texts['invalidCredentials']!);
      }
    } catch (e) {
      _showErrorDialog(context, '${texts['error']!}: $e');
    }
  }

  Future<void> _fetchReservationsForToday() async {
    final response = await Dio().post(
      'http://${globals.pcIP}/api/list_reservations/',
      data: {
        'group': globals.globalGroup ?? '',
        'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      },
      options: Options(
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      ),
    );

    if (response.statusCode == 200) {
      final data =
          response.data is String ? jsonDecode(response.data) : response.data;
      if (data['status'] == 'success') {
        globals.globalReservations = data['reservations'];
      }
    }
  }

  bool _isValidLogin(String login) {
    // Only allow non-empty, no @ character
    return login.isNotEmpty && !login.contains('@');
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

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Login',
      showLeftButton: false,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 300,
                child: TextField(
                  controller: loginController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: texts['login'],
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
                    texts['loginButton']!,
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

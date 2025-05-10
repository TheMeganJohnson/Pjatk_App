import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'home_page.dart';
import 'globals.dart' as globals;
import 'main.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final String _errorMessage = '';
  final Map<String, String> localCredentials = {
    'admin': '123',
  };
  late Map<String, String> texts;

  @override
  void initState() {
    super.initState();

    // Initialize texts based on the current language
    _updateTexts();

    // Listen to language changes
    globals.languageNotifier.addListener(_onLanguageChange);
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
      'email': 'Email',
      'password': 'Hasło',
      'login': 'Zaloguj',
      'invalidEmailOrLogin': 'Podaj poprawny email lub login.',
      'invalidCredentials': 'Złe hasło lub email. Spróbuj ponownie.',
      'error': 'Błąd',
      'ok': 'OK',
    };

    final Map<String, String> englishTexts = {
      'email': 'Email',
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

  Future<void> _login(BuildContext context) async {
    String emailOrLogin = emailController.text;
    String password = passwordController.text;

    // Check local credentials first
    if (localCredentials.containsKey(emailOrLogin) &&
        localCredentials[emailOrLogin] == password) {
      globals.globalFullName = 'Local User';
      globals.globalUserType = 'Admin';
      globals.globalAssigned = true;
      globals.globalEmail = 'local@example.com';
      globals.globalGroup = 'Local Group';

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
      return;
    }

    if (!_isValidEmail(emailOrLogin) && !_isValidLogin(emailOrLogin)) {
      _showErrorDialog(context, texts['invalidEmailOrLogin']!);
      return;
    }

    final response = await http.post(
      Uri.parse('http://192.168.0.248:8000/api/check_login/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'login': emailOrLogin,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        final userData = data['user_data'];
        globals.globalFullName = '${userData['name']} ${userData['surname']}';
        globals.globalUserType =
            userData['permissions'] == 1 ? 'Admin' : 'Student';
        globals.globalAssigned = userData['isAuthenticated'] == 1;
        globals.globalEmail = userData['email'];
        globals.globalGroup = userData['group'];

        await _fetchReservationsForToday();

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        _showErrorDialog(context, data['message']);
      }
    } else {
      _showErrorDialog(context, texts['invalidCredentials']!);
    }
  }

  Future<void> _fetchReservationsForToday() async {
    final response = await http.post(
      Uri.parse('http://192.168.0.248:8000/api/list_reservations/'),
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

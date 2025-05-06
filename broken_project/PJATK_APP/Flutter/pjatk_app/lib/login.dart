import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // Import the intl package for date formatting
import 'home_page.dart';
import 'globals.dart' as globals;

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final String _errorMessage = '';

  Future<void> _login(BuildContext context) async {
    String emailOrLogin = emailController.text;
    String password = passwordController.text;

    if (!_isValidEmail(emailOrLogin) && !_isValidLogin(emailOrLogin)) {
      _showErrorDialog(context, 'Podaj poprawny email lub login.');
      return;
    }

    final response = await http.post(
      Uri.parse(
          'http://192.168.0.104:8000/api/check_login/'), // Update with your local IP address
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
        globals.globalUserType = userData['permissions'] == 1
            ? 'Admin'
            : 'Student'; // Set user type based on permissions
        globals.globalAssigned =
            userData['isAuthenticated'] == 1; // Ensure boolean type
        globals.globalEmail = userData['email'];
        globals.globalGroup = userData['group'];

        // Fetch reservations for today
        await _fetchReservationsForToday();

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage()), // Navigate to the home page
        );
      } else {
        _showErrorDialog(context, data['message']);
      }
    } else {
      _showErrorDialog(context, 'Złe hasło lub email. Spróbuj ponownie.');
    }
  }

  Future<void> _fetchReservationsForToday() async {
    final response = await http.post(
      Uri.parse(
          'http://192.168.0.104:8000/api/list_reservations/'), // Update with your local IP address
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'group': globals.globalGroup ?? '',
        'date': DateFormat('yyyy-MM-dd')
            .format(DateTime.now()), // Fetch reservations for today
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        globals.globalReservations = data['reservations'];
        print(
            'Reservations fetched: ${globals.globalReservations}'); // Debugging: Print the fetched reservations
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
    // Add your login validation logic here if needed
    return login.isNotEmpty;
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back button
        title: Stack(
          children: [
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'images/logo-pjwstk.png',
                    height: 40,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 300, // Set the desired width here
                child: TextField(
                  controller: emailController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                    alignLabelWithHint: true,
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              SizedBox(
                width: 300, // Set the desired width here
                child: TextField(
                  controller: passwordController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Hasło',
                    alignLabelWithHint: true,
                  ),
                  obscureText: true,
                ),
              ),
              SizedBox(height: 16.0),
              SizedBox(
                width: 110, // Set the desired width here
                child: ElevatedButton(
                  onPressed: () => _login(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFED1C24), // Button color
                  ),
                  child: Text(
                    'Zaloguj',
                    style: TextStyle(color: Colors.white), // Text color
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

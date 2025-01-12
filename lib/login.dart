// filepath: /c:/Users/coret/Documents/Flutter/pjatk_app/lib/login.dart
import 'package:flutter/material.dart';
import 'main.dart';
import 'home_page.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
              SizedBox(height: 16.0), // Space between the text fields
              SizedBox(
                width: 300, // Set the desired width here
                child: TextField(
                  controller: passwordController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    alignLabelWithHint: true,
                  ),
                  obscureText: true, // Hide the password text
                ),
              ),
              SizedBox(
                  height: 16.0), // Space between the text fields and the button
              SizedBox(
                width: 100, // Set the desired width here
                child: ElevatedButton(
                  onPressed: () {
                    if (emailController.text == 'admin' &&
                        passwordController.text == '123') {
                      emailController.clear();
                      passwordController.clear();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Invalid credentials'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFED1C24), // Button color
                  ),
                  child: Text(
                    'Log In',
                    style: TextStyle(color: Colors.white), // Text color
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: LoginPage(),
  ));
}

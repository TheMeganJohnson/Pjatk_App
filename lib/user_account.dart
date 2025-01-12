// filepath: /c:/Users/coret/Documents/Flutter/pjatk_app/lib/user_account.dart
import 'package:flutter/material.dart';
import 'main.dart';
import 'login.dart';

class UserAccountPage extends StatelessWidget {
  const UserAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'User Account',
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFED1C24), // Button color
          ),
          child: Text(
            'Logout',
            style: TextStyle(color: Colors.white), // Text color
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'globals.dart' as globals;
import 'login.dart';
import 'main.dart';

class UserAccountPage extends StatefulWidget {
  @override
  _UserAccountPageState createState() => _UserAccountPageState();
}

class _UserAccountPageState extends State<UserAccountPage> {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Konto użytkownika',
      leftButtonAction: () => Navigator.pop(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Email:', globals.globalEmail ?? ''),
                  _buildDetailRow(
                      'Imię i Nazwisko:', globals.globalFullName ?? ''),
                  _buildDetailRow(
                      'Typ użytkownika:', globals.globalUserType ?? ''),
                  _buildDetailRow('UID Karty:', globals.globalCardUID ?? ''),
                  _buildDetailRow('Przypisano telefon?',
                      globals.globalAssigned == true ? 'Tak' : 'Nie'),
                ],
              ),
            ),
            Spacer(),
            Center(
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
                  'Wyloguj',
                  style: TextStyle(color: Colors.white), // Text color
                ),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'globals.dart' as globals;
import 'login.dart';
import 'main.dart';

class UserAccountPage extends StatefulWidget {
  @override
  _UserAccountPageState createState() => _UserAccountPageState();
}

class _UserAccountPageState extends State<UserAccountPage> {
  @override
  void initState() {
    super.initState();

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
      // Rebuild the widget when the language changes
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define translated texts for both languages
    final Map<String, String> polishTexts = {
      'title': 'Konto użytkownika',
      'email': 'Email:',
      'fullName': 'Imię i Nazwisko:',
      'userType': 'Typ użytkownika:',
      'cardUID': 'UID Karty:',
      'assignedPhone': 'Przypisano telefon?',
      'yes': 'Tak',
      'no': 'Nie',
      'logout': 'Wyloguj',
    };

    final Map<String, String> englishTexts = {
      'title': 'User Account',
      'email': 'Email:',
      'fullName': 'Full Name:',
      'userType': 'User Type:',
      'cardUID': 'Card UID:',
      'assignedPhone': 'Assigned Phone?',
      'yes': 'Yes',
      'no': 'No',
      'logout': 'Log Out',
    };

    // Choose the appropriate texts based on the global language setting
    final Map<String, String> texts = globals.globalLanguagePolish == true
        ? polishTexts
        : englishTexts;

    return BasePage(
      title: texts['title']!,
      leftButtonAction: () => Navigator.pop(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor, // Use theme's card color
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.2) // Thin white border for dark mode
                      : Colors.black.withOpacity(0.1), // Thin black border for light mode
                  width: 1.0, // Border thickness
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.05) // Light shadow for dark mode
                        : Colors.black.withOpacity(0.1), // Dark shadow for light mode
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: Offset(0, 4), // Slightly raised shadow
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(texts['email']!, globals.globalEmail ?? ''),
                  _buildDetailRow(
                      texts['fullName']!, globals.globalFullName ?? ''),
                  _buildDetailRow(
                      texts['userType']!, globals.globalUserType ?? ''),
                  //_buildDetailRow(texts['cardUID']!, globals.globalCardUID ?? ''),
                  //_buildDetailRow(
                  //  texts['assignedPhone']!,
                  //  globals.globalAssigned == true ? texts['yes']! : texts['no']!,
                  //),
                ],
              ),
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('has_logged_in', false);
                  await prefs.remove('user_pin');
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                    (Route<dynamic> route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFED1C24), // Button color
                ),
                child: Text(
                  texts['logout']!,
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

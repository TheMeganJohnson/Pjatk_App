import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'globals.dart' as globals;
import 'login.dart';
import 'main.dart';

class UserAccountPage extends StatefulWidget {
  const UserAccountPage({super.key});

  @override
  _UserAccountPageState createState() => _UserAccountPageState();
}

class _UserAccountPageState extends State<UserAccountPage> {
  @override
  void initState() {
    super.initState();
    globals.languageNotifier.addListener(_onLanguageChange);
  }

  @override
  void dispose() {
    globals.languageNotifier.removeListener(_onLanguageChange);
    super.dispose();
  }

  void _onLanguageChange() async {
    setState(() {});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('language_polish', globals.globalLanguagePolish ?? true);
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> polishTexts = {
      'title': 'Konto użytkownika',
      'email': 'Email:',
      'fullName': 'Login:',
      'userType': 'Typ użytkownika:',
      'logout': 'Wyloguj',
    };

    final Map<String, String> englishTexts = {
      'title': 'User Account',
      'email': 'Email:',
      'fullName': 'Username:',
      'userType': 'User Type:',
      'logout': 'Log Out',
    };

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
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.1),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: Offset(0, 4),
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
                ],
              ),
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  await prefs.setBool('has_logged_in', false);
                  await prefs.remove('user_pin');
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                    (Route<dynamic> route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFED1C24),
                ),
                child: Text(
                  texts['logout']!,
                  style: TextStyle(color: Colors.white),
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

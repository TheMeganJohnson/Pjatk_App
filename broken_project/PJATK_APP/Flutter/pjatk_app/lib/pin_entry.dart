import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'globals.dart' as globals;
import 'home_page.dart';

class PinEntryPage extends StatefulWidget {
  @override
  _PinEntryPageState createState() => _PinEntryPageState();
}

class _PinEntryPageState extends State<PinEntryPage> {
  final TextEditingController _pinController = TextEditingController();
  String? _error;
  late Map<String, String> texts;

  @override
  void initState() {
    super.initState();
    _updateTexts();
    globals.languageNotifier.addListener(_onLanguageChange);
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
      'enterPin': 'Wprowadź PIN',
      'login': 'Zaloguj',
      'incorrectPin': 'Nieprawidłowy PIN',
    };

    final Map<String, String> englishTexts = {
      'enterPin': 'Enter PIN',
      'login': 'Login',
      'incorrectPin': 'Incorrect PIN',
    };

    texts = globals.globalLanguagePolish == true ? polishTexts : englishTexts;
  }

  Future<void> _checkPin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString('user_pin');
    if (_pinController.text == savedPin) {
      // Restore user info from SharedPreferences
      globals.globalFullName = prefs.getString('user_fullName');
      globals.globalUserType = prefs.getString('user_userType');
      globals.globalAssigned = prefs.getBool('user_assigned') ?? false;
      globals.globalEmail = prefs.getString('user_email');
      globals.globalGroup = prefs.getString('user_group');
      globals.globalIsDarkMode = prefs.getBool('isDarkMode') ?? false;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      setState(() => _error = texts['incorrectPin']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable Android back button
      child: BasePage(
        title: texts['enterPin'] ?? 'Enter PIN',
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
                    controller: _pinController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: texts['enterPin'],
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                  ),
                ),
                SizedBox(height: 16.0),
                SizedBox(
                  width: 110,
                  child: ElevatedButton(
                    onPressed: _checkPin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFED1C24),
                    ),
                    child: Text(
                      texts['login'] ?? 'Login',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      _error!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'globals.dart' as globals;

class PinEntryPage extends StatefulWidget {
  const PinEntryPage({super.key});

  @override
  _PinEntryPageState createState() => _PinEntryPageState();
}

class _PinEntryPageState extends State<PinEntryPage> {
  final TextEditingController _pinController = TextEditingController();
  int _pinTriesLeft = 3;
  String? _error;
  late Map<String, String> texts;

  @override
  void initState() {
    super.initState();
    _updateTexts();
    globals.languageNotifier.addListener(_onLanguageChange);
    _loadTries();
  }

  @override
  void dispose() {
    globals.languageNotifier.removeListener(_onLanguageChange);
    super.dispose();
  }

  void _onLanguageChange() async {
    setState(() {
      _updateTexts();
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('language_polish', globals.globalLanguagePolish ?? true);
  }

  void _updateTexts() {
    final Map<String, String> polishTexts = {
      'enterPin': 'Wprowadź PIN',
      'login': 'Zaloguj',
      'incorrectPin': 'Nieprawidłowy PIN',
      'attemptsLeft': 'Pozostało prób',
      'noTriesLeft': 'Brak prób',
      'loginWithCredentials': 'Zaloguj się loginem i hasłem.',
    };

    final Map<String, String> englishTexts = {
      'enterPin': 'Enter PIN',
      'login': 'Login',
      'incorrectPin': 'Incorrect PIN',
      'attemptsLeft': 'Retries',
      'noTriesLeft': 'No retries left',
      'loginWithCredentials': 'Please log in with your login and password.',
    };

    texts = globals.globalLanguagePolish == true ? polishTexts : englishTexts;
  }

  Future<void> _loadTries() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pinTriesLeft = prefs.getInt('pin_tries_left') ?? 3;
    });
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

      await prefs.setInt('pin_tries_left', 3);
      Navigator.pop(context, true);
    } else {
      _pinTriesLeft--;
      await prefs.setInt('pin_tries_left', _pinTriesLeft);
      _pinController.clear(); // Clear the field after wrong attempt
      if (_pinTriesLeft > 0) {
        setState(() {
          _error = '${texts['incorrectPin']}. ${texts['attemptsLeft']}: $_pinTriesLeft';
        });
      } else {
        await prefs.remove('user_pin');
        await prefs.remove('user_sessionKey');
        await prefs.setInt('pin_tries_left', 3);
        setState(() {
          _error = '${texts['noTriesLeft']}. ${texts['loginWithCredentials']}';
        });
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context).pop(false);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
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
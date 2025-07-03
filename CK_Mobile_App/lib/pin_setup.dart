import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'globals.dart' as globals;

class PinSetupPage extends StatefulWidget {
  const PinSetupPage({super.key});

  @override
  _PinSetupPageState createState() => _PinSetupPageState();
}

class _PinSetupPageState extends State<PinSetupPage> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
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

  void _onLanguageChange() async {
    setState(() {
      _updateTexts();
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('language_polish', globals.globalLanguagePolish ?? true);
  }

  void _updateTexts() {
    final Map<String, String> polishTexts = {
      'setPin': 'Ustaw PIN',
      'enterPin': 'Wprowadź nowy PIN',
      'confirmPin': 'Potwierdź PIN',
      'savePin': 'Zapisz PIN',
      'pinTooShort': 'PIN musi mieć co najmniej 4 cyfry',
      'pinMismatch': 'PIN-y się nie zgadzają',
    };

    final Map<String, String> englishTexts = {
      'setPin': 'Set PIN',
      'enterPin': 'Enter new PIN',
      'confirmPin': 'Confirm PIN',
      'savePin': 'Save PIN',
      'pinTooShort': 'PIN must be at least 4 digits',
      'pinMismatch': 'PINs do not match',
    };

    texts = globals.globalLanguagePolish == true ? polishTexts : englishTexts;
  }

  Future<void> _savePin() async {
    if (_pinController.text.length < 4) {
      setState(() => _error = texts['pinTooShort']);
      return;
    }
    if (_pinController.text != _confirmPinController.text) {
      setState(() => _error = texts['pinMismatch']);
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_pin', _pinController.text);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Disable Android back button
      child: BasePage(
        title: texts['setPin'] ?? 'Set PIN',
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
                  width: 300,
                  child: TextField(
                    controller: _confirmPinController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: texts['confirmPin'],
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                  ),
                ),
                SizedBox(height: 16.0),
                SizedBox(
                  width: 110,
                  child: ElevatedButton(
                    onPressed: _savePin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFED1C24),
                    ),
                    child: Text(
                      texts['savePin'] ?? 'Save PIN',
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
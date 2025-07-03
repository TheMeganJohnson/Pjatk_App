import 'package:flutter/material.dart';
import 'globals.dart' as globals;
import 'main.dart';
import 'sidebar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pin_setup.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Map<String, String> texts = {
    'title': 'Settings',
    'darkMode': 'Dark Mode',
    'resetPin': 'Reset PIN',
    'pinResetSuccess': 'PIN resetted correctly',
  };

  final List<bool> switchValues = [false];
  final List<VoidCallback> switchActions = [];

  @override
  void initState() {
    super.initState();
    _updateTexts();
    globals.languageNotifier.addListener(_onLanguageChange);
    switchValues[0] = globals.globalIsDarkMode ?? false;
    switchActions.addAll([
      () async {
        setState(() {
          switchValues[0] = !switchValues[0];
          globals.globalIsDarkMode = switchValues[0];
          themeNotifier.value = switchValues[0] ? ThemeMode.dark : ThemeMode.light;
        });
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isDarkMode', switchValues[0]);
      },
    ]);
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
      'title': 'Ustawienia',
      'darkMode': 'Tryb Ciemny',
      'resetPin': 'Zresetuj PIN',
      'pinResetSuccess': 'PIN został zresetowany',
    };

    final Map<String, String> englishTexts = {
      'title': 'Settings',
      'darkMode': 'Dark Mode',
      'resetPin': 'Reset PIN',
      'pinResetSuccess': 'PIN resetted correctly',
    };

    texts = globals.globalLanguagePolish == true ? polishTexts : englishTexts;
  }

  Future<void> _resetPin() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PinSetupPage()),
    );
    if (result == true) {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(texts['resetPin'] ?? 'Reset PIN'),
          content: Text(texts['pinResetSuccess'] ?? 'PIN resetted correctly'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: texts['title'] ?? 'Settings',
      leftButtonAction: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SidebarPage()),
        );
      },
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            texts['darkMode'] ?? 'Dark Mode',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Switch(
                          value: switchValues[0],
                          onChanged: (bool value) {
                            switchActions[0]();
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            texts['resetPin'] ?? 'Reset PIN',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _resetPin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFED1C24),
                          ),
                          child: Text(
                            texts['resetPin'] ?? 'Reset PIN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

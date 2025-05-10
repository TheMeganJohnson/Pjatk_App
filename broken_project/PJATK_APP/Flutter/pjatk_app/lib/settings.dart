// filepath: /c:/Users/coret/Documents/Flutter/pjatk_app/lib/settings.dart
import 'package:flutter/material.dart';
import 'globals.dart' as globals;
import 'main.dart';
import 'sidebar.dart';
import 'report.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Map<String, String> texts = {
    'title': 'Settings',
    'darkMode': 'Dark Mode',
    'notifications': 'Notifications',
    'accessibility': 'Accessibility Mode',
    'isWorking': 'Is it working?',
    'reportProblem': 'Report a Problem',
  };

  final List<bool> switchValues = [false, false, false, true];
  final List<VoidCallback> switchActions = [];

  @override
  void initState() {
    super.initState();

    // Initialize texts based on the current language
    _updateTexts();

    // Listen to language changes
    globals.languageNotifier.addListener(_onLanguageChange);

    // Load the state from the global variable
    switchValues[0] = globals.globalIsDarkMode ?? false;

    switchActions.addAll([
      () {
        setState(() {
          switchValues[0] = !switchValues[0];
          globals.globalIsDarkMode = switchValues[0];
          themeNotifier.value = switchValues[0] ? ThemeMode.dark : ThemeMode.light; // Update the theme
        });
      },
      () {
        // Action for the second switch
        print('Notifications toggled');
      },
      () {
        // Action for the third switch
        print('Accessibility Mode toggled');
      },
      () {
        // Action for the fourth switch
        print('Is it working? toggled');
      },
    ]);
  }

  @override
  void dispose() {
    // Remove the listener when the widget is disposed
    globals.languageNotifier.removeListener(_onLanguageChange);
    super.dispose();
  }

  void _onLanguageChange() {
    setState(() {
      // Update texts when the language changes
      _updateTexts();
    });
  }

  void _updateTexts() {
    // Define translated texts for both languages
    final Map<String, String> polishTexts = {
      'title': 'Ustawienia',
      'darkMode': 'Tryb Ciemny',
      'notifications': 'Powiadomienia',
      'accessibility': 'Tryb Dostępności',
      'isWorking': 'Czy działa?',
      'reportProblem': 'Zgłoś Problem',
    };

    final Map<String, String> englishTexts = {
      'title': 'Settings',
      'darkMode': 'Dark Mode',
      'notifications': 'Notifications',
      'accessibility': 'Accessibility Mode',
      'isWorking': 'Is it working?',
      'reportProblem': 'Report a Problem',
    };

    // Choose the appropriate texts based on the global language setting
    texts = globals.globalLanguagePolish == true ? polishTexts : englishTexts;
  }

  void toggleDarkMode() {
    setState(() {
      switchValues[0] = !switchValues[0];
      // Save the state to the global variable
      globals.globalIsDarkMode = switchValues[0];
    });
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
              child: ListView.builder(
                itemCount: 4, // Only iterate over the first 4 items (switches)
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _getPrefilledText(index),
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Switch(
                          value: switchValues[index],
                          onChanged: (bool value) {
                            switchActions[index]();
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Add the "Report a Problem" button explicitly
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ReportPage()),
                  );
                },
                icon: Icon(Icons.bug_report),
                label: Text(texts['reportProblem'] ?? 'Report a Problem'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFED1C24),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPrefilledText(int index) {
    switch (index) {
      case 0:
        return texts['darkMode'] ?? 'Dark Mode';
      case 1:
        return texts['notifications'] ?? 'Notifications';
      case 2:
        return texts['accessibility'] ?? 'Accessibility Mode';
      case 3:
        return texts['isWorking'] ?? 'Is it working?';
      case 4:
        return texts['reportProblem'] ?? 'Report a Problem';
      default:
        return '';
    }
  }
}

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
  final List<String> prefilledTexts = [
    'Tryb Ciemny',
    'Powiadomienia',
    'Tryb Dostępności',
    'Czy działa?',
    'Zgłoś Problem',
  ];

  final List<bool> switchValues = [false, false, false, true];

  @override
  void initState() {
    super.initState();
    // Load the state from the global variable
    switchValues[0] = globals.globalIsDarkMode ?? false;

    switchActions.addAll([
      toggleDarkMode,
      () {
        // Action for the second switch
        print('Powiadomienia toggled');
      },
      () {
        // Action for the third switch
        print('Tryb Dostępności toggled');
      },
      () {
        // Action for the fourth switch
        print('Czy działa? toggled');
      },
    ]);
  }

  void toggleDarkMode() {
    setState(() {
      switchValues[0] = !switchValues[0];
      // Save the state to the global variable
      globals.globalIsDarkMode = switchValues[0];
    });
  }

  final List<VoidCallback> switchActions = [];

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Settings',
      leftButtonAction: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SidebarPage()),
        );
      },
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: prefilledTexts.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      prefilledTexts[index],
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  if (index < 4)
                    Switch(
                      value: switchValues[
                          index], // Set the initial value of the switch
                      onChanged: (bool value) {
                        switchActions[index]();
                      },
                    )
                  else
                    IconButton(
                      icon: Icon(Icons.arrow_forward),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ReportPage()),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

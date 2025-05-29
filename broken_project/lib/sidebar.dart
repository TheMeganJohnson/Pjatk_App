// filepath: /c:/Users/coret/Documents/Flutter/pjatk_app/lib/sidebar.dart
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'main.dart';
import 'user_account.dart';
import 'your_reserve.dart';
import 'globals.dart' as globals;
import 'settings.dart';
import 'testing.dart';

class SidebarPage extends StatefulWidget {
  const SidebarPage({super.key});

  @override
  _SidebarPageState createState() => _SidebarPageState();
}

class _SidebarPageState extends State<SidebarPage> {
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
    // Define button texts for both languages
    final List<String> polishTexts = [
      'Twoje Rezerwacje',
      'Ustawienia',
      'Konto Użytkownika'
    ];

    final List<String> englishTexts = [
      'Your Reservations',
      'Settings',
      'User Account'
    ];

    // Choose the appropriate list based on the global language setting
    final List<String> prefilledTexts = globals.globalLanguagePolish == true
        ? polishTexts
        : englishTexts;

    final List<VoidCallback> buttonActions = [
      () {
        // Navigate to MyReservationsPage
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyReservationsPage()),
        );
      },
      () {
        // Navigate to SettingsPage
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SettingsPage()),
        );
      },
      () {
        // Navigate to UserAccountPage
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserAccountPage()),
        );
      },
    ];

    // Add a new button labeled "Testing"
    prefilledTexts.add('Testing');
    buttonActions.add(() {
      // Define the action for the "Testing" button
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TestingPage()), // Replace with your TestingPage
      );
    });

    return BasePage(
      title: globals.globalLanguagePolish == true ? 'Menu' : 'Sidebar',
      addRightPadding: true,
      leftButtonAction: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      },
      leftButtonIcon: Icons.home,
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: prefilledTexts.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor, // Use theme's card color
                      borderRadius: BorderRadius.circular(8.0),
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
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            prefilledTexts[index],
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyLarge?.color, // Use theme's text color
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_forward),
                          color: Color(0xFFED1C24),
                          onPressed: buttonActions[index],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

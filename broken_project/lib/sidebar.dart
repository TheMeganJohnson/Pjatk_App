// filepath: /c:/Users/coret/Documents/Flutter/pjatk_app/lib/sidebar.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'main.dart';
import 'user_account.dart';
import 'your_reserve.dart';
import 'globals.dart' as globals;
import 'settings.dart';

class SidebarPage extends StatefulWidget {
  const SidebarPage({super.key});

  @override
  _SidebarPageState createState() => _SidebarPageState();
}

class _SidebarPageState extends State<SidebarPage> {
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

    final List<String> prefilledTexts = globals.globalLanguagePolish == true
        ? polishTexts
        : englishTexts;

    final List<VoidCallback> buttonActions = [
      () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyReservationsPage()),
        );
      },
      () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SettingsPage()),
        );
      },
      () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserAccountPage()),
        );
      },
    ];

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
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.2)
                            : Colors.black.withOpacity(0.1),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            prefilledTexts[index],
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyLarge?.color,
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

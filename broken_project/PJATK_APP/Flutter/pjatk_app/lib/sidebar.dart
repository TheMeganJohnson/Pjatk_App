// filepath: /c:/Users/coret/Documents/Flutter/pjatk_app/lib/sidebar.dart
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'main.dart';
import 'user_account.dart';
import 'your_reserve.dart';
import 'globals.dart';
import 'settings.dart';

class SidebarPage extends StatelessWidget {
  const SidebarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> prefilledTexts = [
      'Twoje Rezerwacje',
      'Ustawienia',
      'Konto Użytkownika'
    ];

    final List<VoidCallback> buttonActions = [
      () {
        // Action for the second button
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyReservationsPage()),
        );
      },
      () {
        // Action for the fourth button
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

    // Remove "Nowe Rezerwacje" if the user is a student
    if (globalUserType == 'Student') {
      int index = prefilledTexts.indexOf('Nowe Rezerwacje');
      if (index != -1) {
        prefilledTexts.removeAt(index);
        buttonActions.removeAt(index);
      }
    }

    return BasePage(
      title: 'Sidebar',
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
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Color(0xFF434349)),
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.4),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(prefilledTexts[index])),
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

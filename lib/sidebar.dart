// filepath: /c:/Users/coret/Documents/Flutter/pjatk_app/lib/sidebar.dart
import 'package:flutter/material.dart';
import 'main.dart';
import 'user_account.dart';

class SidebarPage extends StatelessWidget {
  const SidebarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> prefilledTexts = [
      'Your Reservations',
      'New Reservation',
      'Settings',
      'User Account'
    ];

    final List<VoidCallback> buttonActions = [
      () {
        // Action for the first button
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('First button pressed')),
        );
      },
      () {
        // Action for the second button
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Second button pressed')),
        );
      },
      () {
        // Action for the third button
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Third button pressed')),
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

    return BasePage(
      title: 'Sidebar',
      addRightPadding: true,
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: prefilledTexts.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller:
                        TextEditingController(text: prefilledTexts[index]),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.arrow_forward),
                        onPressed: buttonActions[index],
                      ),
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

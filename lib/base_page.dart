// filepath: /c:/Users/coret/Documents/Flutter/pjatk_app/lib/base_scaffold.dart
import 'package:flutter/material.dart';

class BasePage extends StatelessWidget {
  final Widget body;
  final String title;

  const BasePage({
    required this.body,
    required this.title,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Image.asset(
            'images/logo-pjwstk.png',
            height: 40,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('You tapped a button'),
                  duration: Duration(seconds: 2), // Set the duration
                  behavior:
                      SnackBarBehavior.floating, // Make it appear at the top
                  margin: EdgeInsets.only(
                    top: 10.0,
                    left: 10.0,
                    right: 10.0,
                  ), // Adjust the margin
                ),
              );
            },
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 20, // Set the radius to half of the desired diameter
                  backgroundImage: AssetImage(
                      'images/Flag_of_Poland.png'), // Replace with your image path
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black
                            .withValues(alpha: 0.2), // Make the shadow fainter
                      ],
                      stops: [0.6, 1],
                      center: Alignment.center,
                      radius: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            child: Text(title, style: TextStyle(fontSize: 24)),
          ),
          Expanded(child: body),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'v.01 January 2025 | PJATK',
                  style: TextStyle(fontSize: 12),
                ),
                Text(
                  'Magda Kokornacka',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

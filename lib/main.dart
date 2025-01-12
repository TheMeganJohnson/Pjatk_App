import 'package:flutter/material.dart';
import 'login.dart';
import 'sidebar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pjatk App',
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFED1C24)),
        textTheme: TextTheme(
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 16),
        ),
        useMaterial3: true,
      ),
      home: LoginPage(),
    );
  }
}

class BasePage extends StatelessWidget {
  final Widget body;
  final String title;
  final bool addRightPadding;
  final bool isSidebarPage;

  const BasePage({
    required this.body,
    required this.title,
    this.addRightPadding = false,
    this.isSidebarPage = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (isSidebarPage) {
          // Need to change this code
          if (true) Navigator.of(context).pop();
        } else {
          // Need to change this code
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Stack(
            children: [
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'images/logo-pjwstk.png',
                      height: 40,
                    ),
                    if (addRightPadding)
                      SizedBox(width: 48), // Additional padding to the right
                  ],
                ),
              ),
              Positioned(
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('You tapped a button'),
                        duration: Duration(seconds: 2), // Set the duration
                        behavior: SnackBarBehavior
                            .floating, // Make it appear at the top
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
                        radius:
                            20, // Set the radius to half of the desired diameter
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
                              Colors.black.withValues(
                                  alpha: 0.2), // Make the shadow fainter
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
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'login.dart' as login;
import 'testing.dart';
import 'nfc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF434349)),
        textTheme: TextTheme(
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 16),
        ),
        useMaterial3: true,
      ),
      home: login.LoginPage(),
    );
  }
}

class BasePage extends StatelessWidget {
  final Widget body;
  final String title;
  final bool addRightPadding;
  final bool showLeftButton;
  final VoidCallback? leftButtonAction;
  final IconData leftButtonIcon;

  const BasePage({
    required this.body,
    required this.title,
    this.addRightPadding = false,
    this.showLeftButton = true,
    this.leftButtonAction,
    this.leftButtonIcon = Icons.menu,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white, // Turn off the automatic back button
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (showLeftButton)
              IconButton(
                icon: Icon(leftButtonIcon),
                onPressed: leftButtonAction ?? () {},
              ),
            Expanded(
              child: Center(
                child: Image.asset(
                  'images/logo-pjwstk.png',
                  height: 40,
                ),
              ),
            ),
            if (addRightPadding)
              SizedBox(width: 5), // Additional padding to the right
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NFCPage()),
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
                          Colors.black
                              .withOpacity(0.2), // Make the shadow fainter
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
      ),
      body: Container(
        color: Color(0xFFF2F3F8),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: body),
                Container(
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ]),
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'v.04 January 2025 | PJATK',
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

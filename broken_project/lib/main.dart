import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart' as login;
import 'globals.dart' as globals;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  runApp(const MyApp());
}

// Create a ValueNotifier to track the current theme
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentTheme, child) {
        return MaterialApp(
          title: 'Pjatk App',
          theme: ThemeData(
            fontFamily: 'Poppins',
            colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF434349)),
            textTheme: TextTheme(
              headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              bodyLarge: TextStyle(fontSize: 16),
            ),
            dividerTheme: DividerThemeData(
              color: Color(0xFFEBEDF2), // Custom divider color for light theme
              thickness: 1.0,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData.dark().copyWith(
            colorScheme: ThemeData.dark().colorScheme.copyWith(
              primary: Color(0xFFED1C24), // Red for main actions (e.g., logout)
              secondary: Color(0xFFED1C24), // Use blue or another color for accents
            ),
            textTheme: ThemeData.dark().textTheme.apply(
              fontFamily: 'Poppins',
            ),
            primaryTextTheme: ThemeData.dark().primaryTextTheme.apply(
              fontFamily: 'Poppins',
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFED1C24), // Red for main buttons
                foregroundColor: Colors.white,
              ),
            ),
            switchTheme: SwitchThemeData(
              thumbColor: MaterialStateProperty.resolveWith<Color>(
                (states) => Colors.black, // Brighter, neutral thumb
              ),
              trackColor: MaterialStateProperty.resolveWith<Color>(
                (states) => Color.fromARGB(255, 46, 46, 46), // Brighter, neutral track
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFED1C24)!, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFED1C24), width: 2.0),
              ),
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.grey[900]),
          ),
          themeMode: currentTheme, // Dynamically switch between light and dark themes
          home: login.LoginPage(),
        );
      },
    );
  }
}

class BasePage extends StatefulWidget {
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
    super.key,
  });

  @override
  _BasePageState createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.showLeftButton)
              IconButton(
                icon: Icon(widget.leftButtonIcon),
                onPressed: widget.leftButtonAction ?? () {},
              ),
            Expanded(
              child: Center(
                child: Image.asset(
                  'images/logo-pjwstk.png',
                  height: 40,
                ),
              ),
            ),
            if (widget.addRightPadding)
              SizedBox(width: 5),
            GestureDetector(
              onTap: () {
                setState(() {
                  globals.globalLanguagePolish = !(globals.globalLanguagePolish ?? true);
                  globals.languageNotifier.value = globals.globalLanguagePolish!;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // Shadow color
                      blurRadius: 4, // Blur radius for the shadow
                      offset: Offset(0, 4), // Offset for the shadow
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage(
                    globals.globalLanguagePolish == true
                        ? 'images/Flag_of_Poland.png'
                        : 'images/Flag_of_the_United_Kingdom.png',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor, // Use theme's background color
        child: Column(
          children: [
            Expanded(
              child: widget.body,
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).appBarTheme.backgroundColor, // Use theme's app bar color
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'v.07 May 2025 | PJATK',
                    style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                  Text(
                    'Magda Kokornacka',
                    style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyLarge?.color),
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

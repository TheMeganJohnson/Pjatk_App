import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart' as login;
import 'globals.dart' as globals;

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    globals.globalLanguagePolish = prefs.getBool('language_polish') ?? true;
    themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    runApp(const MyApp());
  } catch (e) {
    WidgetsFlutterBinding.ensureInitialized();
    globals.globalLanguagePolish = true;
    themeNotifier.value = ThemeMode.light;
    runApp(const MyApp());
  }
}

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentTheme, child) {
        return MaterialApp(
          title: 'CK Mobile',
          theme: ThemeData(
            fontFamily: 'Poppins',
            colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF434349)),
            textTheme: TextTheme(
              headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              bodyLarge: TextStyle(fontSize: 16),
            ),
            dividerTheme: DividerThemeData(
              color: Color(0xFFEBEDF2),
              thickness: 1.0,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData.dark().copyWith(
            colorScheme: ThemeData.dark().colorScheme.copyWith(
              primary: Color(0xFFED1C24),
              secondary: Color(0xFFED1C24),
            ),
            textTheme: ThemeData.dark().textTheme.apply(
              fontFamily: 'Poppins',
            ),
            primaryTextTheme: ThemeData.dark().primaryTextTheme.apply(
              fontFamily: 'Poppins',
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFED1C24),
                foregroundColor: Colors.white,
              ),
            ),
            switchTheme: SwitchThemeData(
              thumbColor: WidgetStateProperty.resolveWith<Color>(
                (states) => Colors.black, 
              ),
              trackColor: WidgetStateProperty.resolveWith<Color>(
                (states) => Color.fromARGB(255, 46, 46, 46),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFED1C24), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFED1C24), width: 2.0),
              ),
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.grey[900]),
          ),
          themeMode: currentTheme,
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
  BasePageState createState() => BasePageState();
}

class BasePageState extends State<BasePage> {
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
                  'images/logo_app.png',
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
                      color: Colors.black.withValues(alpha: .2),
                      blurRadius: 4, 
                      offset: Offset(0, 4),
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
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            Expanded(
              child: widget.body,
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).appBarTheme.backgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .1),
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
                    'v.09 June 2025 | PJATK',
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

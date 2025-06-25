import 'package:flutter/material.dart';
import 'package:pjatk_app/home_page.dart';
import '../globals.dart' as globals;
import '../main.dart'; // Ensure main.dart is imported

class NewReservationFinishPage extends StatefulWidget {
  const NewReservationFinishPage({super.key});

  @override
  _NewReservationFinishPageState createState() =>
      _NewReservationFinishPageState();
}

class _NewReservationFinishPageState extends State<NewReservationFinishPage> {
  late Map<String, String> texts = {
    'title': 'Reservation Completed',
    'successMessage': 'Reservation completed successfully!',
    'detailsMessage':
        'Once approved by the administration, it will be available in the schedule with details.',
  };

  @override
  void initState() {
    super.initState();

    // Initialize texts based on the current language
    _updateTexts();

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
      // Update texts when the language changes
      _updateTexts();
    });
  }

  void _updateTexts() {
    // Define translated texts for both languages
    final Map<String, String> polishTexts = {
      'title': 'Rezerwacja Zakończona',
      'successMessage': 'Rezerwacja zakończona pomyślnie!',
      'detailsMessage':
          'Jak zostanie ona zatwierdzona przez administrację, będzie dostępna do podglądu w planie z detalami.',
    };

    final Map<String, String> englishTexts = {
      'title': 'Reservation Completed',
      'successMessage': 'Reservation completed successfully!',
      'detailsMessage':
          'Once approved by the administration, it will be available in the schedule with details.',
    };

    // Choose the appropriate texts based on the global language setting
    texts = globals.globalLanguagePolish == true ? polishTexts : englishTexts;
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: texts['title'] ?? 'Reservation Completed',
      leftButtonAction: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      },
      leftButtonIcon: Icons.home,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                texts['successMessage'] ?? 'Reservation completed successfully!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                '\n${texts['detailsMessage'] ?? 'Once approved by the administration, it will be available in the schedule with details.'}',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../globals.dart' as globals;
import '../main.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController severityController = TextEditingController();

  late Map<String, String> texts = {
    'title': '',
    'bugTitle': '',
    'description': '',
    'impactSeverity': '',
    'submit': '',
    'minor': '',
    'major': '',
    'critical': '',
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
      'title': 'Zgłoś Problem',
      'bugTitle': 'Tytuł Błędu',
      'description': 'Opis',
      'impactSeverity': 'Waga Problemu',
      'submit': 'Wyślij',
      'minor': 'Drobny',
      'major': 'Poważny',
      'critical': 'Krytyczny',
    };

    final Map<String, String> englishTexts = {
      'title': 'Report',
      'bugTitle': 'Bug Title',
      'description': 'Description',
      'impactSeverity': 'Impact Severity',
      'submit': 'Submit',
      'minor': 'Minor',
      'major': 'Major',
      'critical': 'Critical',
    };

    // Choose the appropriate texts based on the global language setting
    texts = globals.globalLanguagePolish == true ? polishTexts : englishTexts;
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: texts['title'] ?? 'Report',
      leftButtonAction: () {
        Navigator.pop(context);
      },
      leftButtonIcon: Icons.arrow_back,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              texts['bugTitle'] ?? 'Bug Title',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: texts['bugTitle'] == 'Tytuł Błędu'
                    ? 'Np. Aplikacja się zawiesza podczas XYZ'
                    : 'E.g. App crashes after XYZ',
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              texts['description'] ?? 'Description',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: texts['description'] == 'Opis'
                    ? 'Opisz kroki do zreprodukowania problemu, np. Po zalogowaniu się i kliknięciu XYZ na stronie ABC aplikacja...'
                    : 'Describe the steps to reproduce the issue, e.g. After logging in and pressing XYZ on page ABC the app...',
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              texts['impactSeverity'] ?? 'Impact Severity',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: [
                texts['minor'] ?? 'Minor',
                texts['major'] ?? 'Major',
                texts['critical'] ?? 'Critical',
              ]
                  .map((severity) => DropdownMenuItem<String>(
                        value: severity,
                        child: Text(severity),
                      ))
                  .toList(),
              onChanged: (value) {
                severityController.text = value!;
              },
            ),
            SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle the submit action
                  print('Bug report submitted');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFED1C24), // Button color
                ),
                child: Text(
                  texts['submit'] ?? 'Submit',
                  style: TextStyle(color: Colors.white), // Text color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

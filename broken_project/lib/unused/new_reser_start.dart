import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../globals.dart' as globals;
import 'new_reser_end.dart'; // Import the new reservation end page

class NewReservationStartPage extends StatefulWidget {
  const NewReservationStartPage({super.key});

  @override
  _NewReservationStartPageState createState() =>
      _NewReservationStartPageState();
}

class _NewReservationStartPageState extends State<NewReservationStartPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _groupController = TextEditingController();

  late Map<String, String> texts = {
    'title': 'New Reservation',
    'general': 'General',
    'overview': 'Overview',
    'reservationName': 'Reservation Name',
    'reservationCode': 'Reservation Code',
    'reservationTime': 'Reservation Time:',
    'day': 'Day',
    'start': 'Start',
    'duration': 'Duration [min]',
    'room': 'Room',
    'group': 'Group',
    'submit': 'Submit',
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
      'title': 'Nowa Rezerwacja',
      'general': 'Ogólne',
      'overview': 'Podgląd',
      'reservationName': 'Nazwa Rezerwacji',
      'reservationCode': 'Kod Rezerwacji',
      'reservationTime': 'Czas Rezerwacji:',
      'day': 'Dzień',
      'start': 'Start',
      'duration': 'Czas [min]',
      'room': 'Sala',
      'group': 'Grupa',
      'submit': 'Potwierdź',
    };

    final Map<String, String> englishTexts = {
      'title': 'New Reservation',
      'general': 'General',
      'overview': 'Overview',
      'reservationName': 'Reservation Name',
      'reservationCode': 'Reservation Code',
      'reservationTime': 'Reservation Time:',
      'day': 'Day',
      'start': 'Start',
      'duration': 'Duration [min]',
      'room': 'Classroom',
      'group': 'Group',
      'submit': 'Submit',
    };

    // Choose the appropriate texts based on the global language setting
    texts = globals.globalLanguagePolish == true ? polishTexts : englishTexts;
  }

  void _navigateToEndPage() {
    if (_formKey.currentState!.validate()) {
      final String name = _nameController.text;
      final String code = _codeController.text;
      final String day = _dayController.text;
      final String start = _startController.text;
      final int duration = int.tryParse(_durationController.text) ?? 90;
      final String room = _roomController.text;
      final String group = _groupController.text;
      final String user = globals.globalFullName ?? '';

      // Combine the day and hour provided by the user to form the complete datetime
      final DateTime fromDateTime =
          DateFormat('yyyy-MM-dd HH:mm').parse('2025-$day $start');
      final DateTime toDateTime = fromDateTime.add(Duration(minutes: duration));

      print('from_datetime: $fromDateTime, to_datetime: $toDateTime');

      final newReservation = {
        'name': name,
        'room': room,
        'code': code,
        'duration_minutes': duration,
        'from_datetime': fromDateTime.toIso8601String(),
        'to_datetime': toDateTime.toIso8601String(),
        'group': group,
        'user': user,
        'color': '66ccff', // Example color, adjust as needed
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewReservationEndPage(
            newReservation: newReservation,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: texts['title'] ?? 'New Reservation',
      leftButtonAction: () => Navigator.pop(context),
      leftButtonIcon: Icons.arrow_back,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      texts['general'] ?? 'General',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 16.0),
                    Text(
                      texts['overview'] ?? 'Overview',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              _buildTextFormField(
                controller: _nameController,
                labelText: texts['reservationName'] ?? 'Reservation Name',
              ),
              SizedBox(height: 16.0),
              _buildTextFormField(
                controller: _codeController,
                labelText: texts['reservationCode'] ?? 'Reservation Code',
              ),
              SizedBox(height: 16.0),
              Text(
                texts['reservationTime'] ?? 'Reservation Time:',
                style: TextStyle(fontSize: 16),
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: _dayController,
                      labelText: texts['day'] ?? 'Day',
                      hintText: 'MM-dd',
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: _buildTextFormField(
                      controller: _startController,
                      labelText: texts['start'] ?? 'Start',
                      hintText: 'HH:mm',
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: _buildTextFormField(
                      controller: _durationController,
                      labelText: texts['duration'] ?? 'Duration [min]',
                      hintText: 'minutes',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: _roomController,
                      labelText: texts['room'] ?? 'Room',
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: _buildTextFormField(
                      controller: _groupController,
                      labelText: texts['group'] ?? 'Group',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Center(
                child: ElevatedButton(
                  onPressed: _navigateToEndPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFED1C24), // Button color
                    padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0), // Add padding for better appearance
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
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // Use theme's card color
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.2) // Thin white border for dark mode
              : Colors.black.withOpacity(0.1), // Thin black border for light mode
          width: 1.0, // Border thickness
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.05) // Light shadow for dark mode
                : Colors.black.withOpacity(0.1), // Dark shadow for light mode
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 4), // Slightly raised shadow
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          filled: true,
          fillColor: Theme.of(context).cardColor, // Use theme's card color
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none, // Remove default border
          ),
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $labelText';
          }
          return null;
        },
      ),
    );
  }
}

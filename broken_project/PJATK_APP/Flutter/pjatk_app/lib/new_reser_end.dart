import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart'; // Ensure main.dart is imported
import 'new_reser_finish.dart'; // Import the finish page
import 'globals.dart' as globals; // Import your globals file

class NewReservationEndPage extends StatefulWidget {
  final Map<String, dynamic> newReservation;

  const NewReservationEndPage({Key? key, required this.newReservation})
      : super(key: key);

  @override
  _NewReservationEndPageState createState() => _NewReservationEndPageState();
}

class _NewReservationEndPageState extends State<NewReservationEndPage> {
  List<Map<String, dynamic>> reservations = [];
  late Map<String, String> texts = {
    'title': 'New Reservation',
    'general': 'General',
    'overview': 'Overview',
    'room': 'Room',
    'finish': 'Finish',
  };

  @override
  void initState() {
    super.initState();

    // Initialize texts based on the current language
    _updateTexts();

    // Listen to language changes
    globals.languageNotifier.addListener(_onLanguageChange);

    // Fetch reservations
    _fetchReservations();
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
      'room': 'Sala',
      'finish': 'Zakończ',
    };

    final Map<String, String> englishTexts = {
      'title': 'New Reservation',
      'general': 'General',
      'overview': 'Overview',
      'room': 'Classroom',
      'finish': 'Finish',
    };

    // Choose the appropriate texts based on the global language setting
    texts = globals.globalLanguagePolish == true ? polishTexts : englishTexts;
  }

  Future<void> _fetchReservations() async {
    final group = widget.newReservation['group'];
    final date = DateFormat('yyyy-MM-dd')
        .format(DateTime.parse(widget.newReservation['from_datetime']));

    print(
        'Fetching reservations for group: $group on date: $date'); // Debug print

    final response = await http.post(
      Uri.parse(
          'http://192.168.0.248:8000/api/list_reservations/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'group': group,
        'date': date,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          reservations = List<Map<String, dynamic>>.from(data['reservations']);
          reservations.add(widget
              .newReservation); // Add the new reservation with 0.5 opacity
        });
        print(
            'Reservations fetched successfully: $reservations'); // Debug print
      } else {
        print('Failed to fetch reservations: ${data['message']}');
      }
    } else {
      print('Failed to fetch reservations: ${response.reasonPhrase}');
    }
  }

  Future<void> _submitReservation() async {
    final response = await http.post(
      Uri.parse(
          'http://192.168.0.248:8000/api/create_reservation/'), // Update with your local IP address
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(widget.newReservation),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NewReservationFinishPage()),
        );
      } else {
        _showErrorDialog('Whoops, something went wrong: ${data['message']}');
      }
    } else {
      _showErrorDialog(
          'Whoops, something went wrong: ${response.reasonPhrase}');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Color _parseColor(String colorString, {double opacity = 1.0}) {
    return Color(int.parse(colorString, radix: 16) + 0xFF000000)
        .withOpacity(opacity);
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the reservation's start and end times
    final reservationStartTime =
        DateTime.parse(widget.newReservation['from_datetime']);
    final reservationEndTime = reservationStartTime
        .add(Duration(minutes: widget.newReservation['duration_minutes']));

    // Ensure the datetime is formatted correctly
    final String reservationStartTimeFormatted =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(reservationStartTime);
    final String reservationEndTimeFormatted =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(reservationEndTime);

    return BasePage(
      title: texts['title'] ?? 'New Reservation',
      leftButtonAction: () => Navigator.pop(context),
      leftButtonIcon: Icons.arrow_back,
      body: Column(
        children: [
          SizedBox(height: 16.0), // Add some space above the row
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  texts['general'] ?? 'General',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
                SizedBox(width: 16.0),
                Text(
                  texts['overview'] ?? 'Overview',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.0),
          Expanded(
            child: Container(
              height: 400.0, // Set a fixed height for the container
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16.0), // Rounded edges
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.2) // Thin white border for dark mode
                    : Colors.black.withOpacity(0.1), // Thin black border for light mode
                width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.05) // Light shadow for dark mode
                      : Colors.black.withOpacity(0.1), // Dark shadow for light mode
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                  ),
                ],
              ),
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Stack(
                  children: [
                    Column(
                      children: List.generate(16, (index) {
                        final time = DateTime(2025, 1, 1, 6 + index);
                        final isHalfHour = time.minute == 30;
                        return Container(
                          height: 60.0,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 50.0,
                                child: Text(
                                  isHalfHour
                                      ? '${time.hour.toString().padLeft(2, '0')}:30'
                                      : '${time.hour.toString().padLeft(2, '0')}:00',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.grey[300],
                                  thickness: 1.0,
                                  endIndent:
                                      16.0, // Ensure lines end at the same place
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                    // Reservation boxes
                    ...reservations.map((reservation) {
                      final reservationStartTime =
                          DateTime.parse(reservation['from_datetime']);
                      final duration = reservation['duration_minutes'];
                      final topOffset = (reservationStartTime.hour - 6) * 60 +
                          reservationStartTime.minute;
                      final boxHeight = duration.toDouble();
                      final isNewReservation =
                          reservation == widget.newReservation;

                      return Positioned(
                        top: topOffset.toDouble(),
                        left: 50.0,
                        right: 16.0,
                        height: boxHeight,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                          color: _parseColor(reservation['color'], opacity: isNewReservation ? 0.5 : 1.0),
                          borderRadius: BorderRadius.circular(8.0),
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
                          child: ListTile(
                            title: Text(
                              '${reservation['code']}', // Display reservation code
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black), // Text color black
                            ),
                            subtitle: Text(
                              '${texts['room'] ?? 'Room'}: ${reservation['room']}, ${DateFormat('HH:mm').format(reservationStartTime)}',
                              style: TextStyle(
                                  color: Colors.black), // Text color black
                            ),
                            onTap: () {
                              // Handle tap if needed
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _submitReservation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFED1C24), // Red background colo
          
                elevation: 2.0, // Slight shadow for a raised effect
              ),
              child: Text(
                texts['finish'] ?? 'Finish',
                style: TextStyle(
                  color: Colors.white, // White text color
                  fontWeight: FontWeight.bold, // Bold text for emphasis
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

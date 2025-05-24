import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'globals.dart' as globals;
import 'new_reser_start.dart';
import 'main.dart';
import 'reservation_details.dart'
    as details; // Import the reservation details page with a prefix

class MyReservationsPage extends StatefulWidget {
  const MyReservationsPage({super.key});

  @override
  _MyReservationsPageState createState() => _MyReservationsPageState();
}

class _MyReservationsPageState extends State<MyReservationsPage> {
  DateTime selectedDate = DateTime.now();
  List<String> dates = [];
  List<Map<String, dynamic>> selectedDateReservations = [];
  late Map<String, String> texts = {
    'title': '',
    'room': '',
    'verified': '',
    'unverified': '',
    'noReservations': '',
  };

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Initialize texts based on the current language
    _updateTexts();

    // Listen to language changes
    globals.languageNotifier.addListener(_onLanguageChange);

    // Initialize dates and fetch reservations
    _initializeDates();
    _fetchReservationsForSelectedDate();

    // Start a timer to update the UI every minute
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // Remove the listener when the widget is disposed
    globals.languageNotifier.removeListener(_onLanguageChange);

    // Cancel the timer
    _timer?.cancel();

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
      'title': 'Moje Rezerwacje',
      'room': 'Sala',
      'verified': 'Zweryfikowane',
      'unverified': 'Niezweryfikowane',
      'noReservations': 'Brak rezerwacji na wybrany dzień',
    };

    final Map<String, String> englishTexts = {
      'title': 'My Reservations',
      'room': 'Classroom',
      'verified': 'Verified',
      'unverified': 'Unverified',
      'noReservations': 'No reservations for the selected day',
    };

    // Choose the appropriate texts based on the global language setting
    texts = globals.globalLanguagePolish == true ? polishTexts : englishTexts;
  }

  void _initializeDates() {
    // Initialize the dates list with the next 7 days
    for (int i = 0; i < 7; i++) {
      dates.add(DateFormat('yyyy-MM-dd')
          .format(DateTime.now().add(Duration(days: i))));
    }
  }

  Future<void> _fetchReservationsForSelectedDate() async {
    final response = await http.post(
      Uri.parse(
          'http://192.168.0.248:8000/api/list_reservations/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'group': globals.globalGroup ?? '',
        'date': DateFormat('yyyy-MM-dd')
            .format(selectedDate), // Fetch reservations for the selected date
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          selectedDateReservations =
              List<Map<String, dynamic>>.from(data['reservations']);
        });
      } else {
        print('Failed to fetch reservations: ${data['message']}');
      }
    } else {
      print('Failed to fetch reservations: ${response.reasonPhrase}');
    }
  }

  double? _calculateCurrentTimeOffset() {
    final now = DateTime.now();
    if (now.hour < 6 || now.hour >= 20) {
      // Outside timetable hours
      return null;
    }
    final minutesSinceStart = (now.hour - 6) * 60 + now.minute;
    return minutesSinceStart.toDouble();
  }

  Color _parseColor(String colorString, {bool isDarkMode = false}) {
  // Parse the color from the database
  Color baseColor = Color(int.parse(colorString, radix: 16) + 0xFF000000);

  // If dark mode is enabled, darken the color
  if (isDarkMode) {
    baseColor = baseColor.withRed((baseColor.red * 0.8).toInt())
                         .withGreen((baseColor.green * 0.8).toInt())
                         .withBlue((baseColor.blue * 0.8).toInt());
  }

  return baseColor;
}

  @override
  Widget build(BuildContext context) {
    final currentTimeOffset = _calculateCurrentTimeOffset();

    return BasePage(
      title: texts['title']!,
      leftButtonAction: () => Navigator.pop(context),
      leftButtonIcon: Icons.arrow_back,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                DropdownButton<String>(
                  value: DateFormat('yyyy-MM-dd').format(selectedDate),
                  items: dates.map((String date) {
                    final parsedDate = DateFormat('yyyy-MM-dd').parse(date);
                    final displayDate = DateFormat('dd MMM').format(parsedDate); // e.g., 24 May
                    return DropdownMenuItem<String>(
                      value: date,
                      child: Text(displayDate),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedDate = DateFormat('yyyy-MM-dd').parse(newValue!);
                      _fetchReservationsForSelectedDate(); // Fetch reservations for the selected date
                    });
                  },
                ),
                Spacer(), // Add a spacer to push the text to the right
                Text(
                  texts['title']!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (globals.globalUserType !=
                    'Student') // Conditionally display the plus icon
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                NewReservationStartPage()), // Navigate to the new reservation start page
                      );
                    },
                  ),
                  IconButton(
      icon: Icon(Icons.refresh),
      onPressed: () {
        _fetchReservationsForSelectedDate(); // Refresh data for the selected date
      },
    ),
                Spacer(), // Add a spacer to push the text to the center
              ],
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.all(
                      16.0), // Add margin to move away from edges
                  height: 960.0, // Adjusted height to fix bottom overflow issue
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor, // Use theme's card color
                    borderRadius:
                        BorderRadius.circular(16.0), // More rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 4,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Stack(
                      children: [
                        // Timeline with hours on the left
                        Positioned.fill(
                          child: Column(
                            children: List.generate(15, (index) {
                              return Container(
                                height: 60.0,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Color(0xFF74788D)), // Use theme's divider color
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 50.0,
                                      child: Text(
                                        '${(index + 6).toString().padLeft(2, '0')}:00',
                                        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color), // Use theme's text color
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(// Use theme's divider color
                                        thickness: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                        // Reservation boxes
                        Positioned.fill(
                          child: selectedDateReservations.isNotEmpty
                              ? Stack(
                                  children: selectedDateReservations
                                      .map((reservation) {
                                    final startTime = DateTime.parse(
                                        reservation['from_datetime']);
                                    final duration =
                                        reservation['duration_minutes'];
                                    final topOffset =
                                        (startTime.hour - 6) * 60.0 +
                                            startTime.minute;
                                    final boxHeight = duration.toDouble();

                                    return Positioned(
                                      top: topOffset,
                                      left: 50.0,
                                      right: 16.0,
                                      height: boxHeight,
                                      child: Opacity(
                                        opacity: reservation['verified'] == true ? 1.0 : 0.5,
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => details.ReservationDetailsPage(
                                                  reservationData: reservation,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 4.0),
                                            padding: const EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                              color: _parseColor(
                                                reservation['color'],
                                                isDarkMode: Theme.of(context).brightness == Brightness.dark, // Check if dark mode is active
                                              ),
                                              borderRadius: BorderRadius.circular(8.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.2),
                                                  spreadRadius: 2,
                                                  blurRadius: 4,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: reservation['duration_minutes'] >= 60 // Check if the duration is 30 minutes or more
                                                ? Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        '${reservation['code']}', // Display reservation code
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          color: Theme.of(context).textTheme.bodyLarge?.color,
                                                          fontSize: 13 // Use theme's text color
                                                        ),
                                                      ),
                                                      SizedBox(height: 4.0),
                                                      Text(
                                                        '${texts['room']!}: ${reservation['room']}, ${DateFormat('HH:mm').format(startTime)}',
                                                        style: TextStyle(
                                                          color: Theme.of(context).textTheme.bodyMedium?.color,
                                                          fontSize: 10 // Use theme's text color
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : null, // Do not show text if the duration is less than 30 minutes
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                )
                              : Center(
                      child: Text(
                        texts['noReservations']!,
                        style: TextStyle(fontSize: 16.0, color: Theme.of(context).textTheme.bodyLarge?.color), // Use theme's text color
                      ),
                    ),
                        ),
                        // Current time red line
                      if (currentTimeOffset != null)
                        Positioned(
                          top: currentTimeOffset,
                          left: 0.0, // Extend to the left edge of the timetable
                          right: 0.0, // Extend to the right edge of the timetable
                          child: Container(
                            height: 2.0,
                            margin: const EdgeInsets.only(left: 50.0, right: 16.0), // Boundaries of the timetable
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

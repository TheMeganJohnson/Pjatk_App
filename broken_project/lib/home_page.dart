// filepath: /c:/Users/coret/Documents/Flutter/pjatk_app/lib/home_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'your_reserve.dart';
import 'main.dart';
import 'sidebar.dart';
import 'package:intl/intl.dart';
import 'reservation_details.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> todaysReservations = [];
  late Map<String, String> texts = {
    'upcoming': '',
    'yourReservations': '',
    'view': '',
    'newReservation': '',
    'create': '',
    'noReservations': '',
  };

  @override
  void initState() {
    super.initState();

    // Initialize texts based on the current language
    _updateTexts();

    // Listen to language changes
    globals.languageNotifier.addListener(_onLanguageChange);

    // Fetch reservations when the page loads
    _fetchReservationsForToday();
  }

  @override
  void dispose() {
    // Remove the listener when the widget is disposed
    globals.languageNotifier.removeListener(_onLanguageChange);
    super.dispose();
  }

  void _onLanguageChange() async {
    setState(() {
      // Update texts when the language changes
      _updateTexts();
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('language_polish', globals.globalLanguagePolish ?? true);
  }

  void _updateTexts() {
    // Define translated texts for both languages
    final Map<String, String> polishTexts = {
      'upcoming': 'Dzisiejsze Rezerwacje',
      'yourReservations': 'Twoje \nRezerwacje',
      'view': 'Wyświetl',
      'newReservation': 'Nowa \nRezerwacja',
      'create': 'Stwórz',
      'noReservations': 'Brak nadchodzących rezerwacji',
      'room': 'Sala',
      'notVerified': 'Nie potwierdzona',
    };

    final Map<String, String> englishTexts = {
      'upcoming': "Today's Reservations",
      'yourReservations': 'Your \nReservations',
      'view': 'View',
      'newReservation': 'New \nReservation',
      'create': 'Create',
      'noReservations': 'No upcoming reservations',
      'room': 'Classroom',
      'notVerified': 'Not verified',
    };

    // Choose the appropriate texts based on the global language setting
    texts = globals.globalLanguagePolish == true ? polishTexts : englishTexts;
  }

  Future<void> _fetchReservationsForToday() async {
    final response = await http.post(
      Uri.parse('http://${globals.pcIP}/api/list_reservations/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'group': globals.globalGroup ?? '',
        'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          todaysReservations =
              List<Map<String, dynamic>>.from(data['reservations']);

          // Sort reservations by 'from_datetime'
          todaysReservations.sort((a, b) {
            final DateTime aTime = DateTime.parse(a['from_datetime']);
            final DateTime bTime = DateTime.parse(b['from_datetime']);
            return aTime.compareTo(bTime);
          });
        });
      } else {
        print('Failed to fetch reservations: ${data['message']}');
      }
    } else {
      print('Failed to fetch reservations: ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent popping (back navigation)
      child: BasePage(
        title: 'Home',
        addRightPadding: true,
        leftButtonAction: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SidebarPage()),
          );
        },
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      texts['upcoming']!,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.color, // Use theme's text color
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh,
                          color: Theme.of(context)
                              .iconTheme
                              .color), // Use theme's icon color
                      onPressed: _fetchReservationsForToday,
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0), // Additional padding for the container
                  child: GestureDetector(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .cardColor, // Use theme's card color
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withOpacity(
                                  0.2) // Thin white border for dark mode
                              : Colors.black.withOpacity(
                                  0.1), // Thin black border for light mode
                          width: 1.0, // Border thickness
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white.withOpacity(
                                        0.05) // Light shadow for dark mode
                                    : Colors.black.withOpacity(
                                        0.1), // Dark shadow for light mode
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: Offset(0, 4), // Slightly raised shadow
                          ),
                        ],
                      ),
                      child: todaysReservations.isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: todaysReservations.length,
                              itemBuilder: (context, index) {
                                final reservation = todaysReservations[index];
                                final isVerified =
                                    reservation['verified'] == true;

                                return ListTile(
                                  title: Text(
                                    reservation['name'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${texts['room']}: ${reservation['room']}, ${DateFormat('HH:mm').format(DateTime.parse(reservation['from_datetime']))}'
                                    '${isVerified ? '' : ' - ${texts['notVerified'] ?? 'Not verified'}'}',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ReservationDetailsPage(
                                                reservationData: reservation),
                                      ),
                                    );
                                  },
                                );
                              },
                            )
                          : Text(
                              texts['noReservations']!,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(height: 24.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0), // Align with above
                  child: Builder(
                    builder: (context) {
                      // Make the square about 10% smaller
                      double side = ((MediaQuery.of(context).size.width - 48 - 16) / 2) * 0.9;
                      return SizedBox(
                        width: side,
                        height: side,
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12.0),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12.0),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyReservationsPage(),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white.withOpacity(0.2)
                                      : Colors.black.withOpacity(0.1),
                                  width: 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white.withOpacity(0.05)
                                        : Colors.black.withOpacity(0.1),
                                    spreadRadius: 2,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                                color: Theme.of(context).cardColor,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.event_note,
                                    color: Color(0xFFED1C24),
                                    size: side * 0.35,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    texts['yourReservations']!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                    height:
                        32.0), // Extra space at the bottom for full shadow visibility
              ],
            ),
          ),
        ),
      ),
    );
  }
}

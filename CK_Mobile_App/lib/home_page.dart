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

    _updateTexts();

    globals.languageNotifier.addListener(_onLanguageChange);

    _fetchReservationsForToday();
  }

  @override
  void dispose() {
    globals.languageNotifier.removeListener(_onLanguageChange);
    super.dispose();
  }

  void _onLanguageChange() async {
    setState(() {
      _updateTexts();
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('language_polish', globals.globalLanguagePolish ?? true);
  }

  void _updateTexts() {
    final Map<String, String> polishTexts = {
      'upcoming': 'Dzisiejsze Rezerwacje',
      'yourReservations': 'Twoje \nRezerwacje',
      'view': 'Wyświetl',
      'newReservation': 'Nowa \nRezerwacja',
      'create': 'Stwórz',
      'noReservations': 'Brak nadchodzących rezerwacji',
      'room': 'Sala',
    };

    final Map<String, String> englishTexts = {
      'upcoming': "Today's Reservations",
      'yourReservations': 'Your \nReservations',
      'view': 'View',
      'newReservation': 'New \nReservation',
      'create': 'Create',
      'noReservations': 'No upcoming reservations',
      'room': 'Classroom',
    };

    texts = globals.globalLanguagePolish == true ? polishTexts : englishTexts;
  }

  Future<void> _fetchReservationsForToday() async {
  final response = await http.post(
    Uri.parse('https://${globals.pcIP}/api/list_reservations/'),
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

          todaysReservations.sort((a, b) {
            final DateTime aTime = DateTime.parse(a['from_datetime']);
            final DateTime bTime = DateTime.parse(b['from_datetime']);
            return aTime.compareTo(bTime);
          });
        });
      } else {
      }
    } else {
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
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
                            ?.color,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh,
                          color: Theme.of(context)
                              .iconTheme
                              .color),
                      onPressed: _fetchReservationsForToday,
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0),
                  child: GestureDetector(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .cardColor,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withValues(
                                  alpha: 0.2)
                              : Colors.black.withValues(
                                  alpha: 0.1),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white.withValues(
                                        alpha: 0.05)
                                    : Colors.black.withValues(
                                        alpha: 0.1),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: Offset(0, 4),
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
                                    '${texts['room']}: ${reservation['room']}, ${DateFormat('HH:mm').format(DateTime.parse(reservation['from_datetime']))}',
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
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Builder(
                    builder: (context) {
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
                                      ? Colors.white.withValues(alpha: 0.2)
                                      : Colors.black.withValues(alpha: 0.1),
                                  width: 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : Colors.black.withValues(alpha: 0.1),
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
                        32.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

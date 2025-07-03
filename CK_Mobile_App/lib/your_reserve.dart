import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'globals.dart' as globals;
import 'main.dart';
import 'reservation_details.dart'
    as details;

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
    'noReservations': '',
  };

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateTexts();
    globals.languageNotifier.addListener(_onLanguageChange);
    _initializeDates();
    _fetchReservationsForSelectedDate();
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    globals.languageNotifier.removeListener(_onLanguageChange);
    _timer?.cancel();
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
      'title': 'Moje Rezerwacje',
      'room': 'Sala',
      'noReservations': 'Brak rezerwacji na wybrany dzień',
    };

    final Map<String, String> englishTexts = {
      'title': 'My Reservations',
      'room': 'Classroom',
      'noReservations': 'No reservations for the selected day',
    };

    texts = globals.globalLanguagePolish == true ? polishTexts : englishTexts;
  }

  void _initializeDates() {
    for (int i = 0; i < 7; i++) {
      dates.add(DateFormat('yyyy-MM-dd')
          .format(DateTime.now().add(Duration(days: i))));
    }
  }

  Future<void> _fetchReservationsForSelectedDate() async {
  final response = await http.post(
    Uri.parse('https://${globals.pcIP}/api/list_reservations/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'group': globals.globalGroup ?? '',
        'date': DateFormat('yyyy-MM-dd')
            .format(selectedDate),
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
      }
    } else {
    }
  }

  double? _calculateCurrentTimeOffset() {
    final now = DateTime.now();
    if (now.hour < 6 || now.hour >= 20) {
      return null;
    }
    final minutesSinceStart = (now.hour - 6) * 60 + now.minute;
    return minutesSinceStart.toDouble();
  }

  Color _parseColor(String colorString, {bool isDarkMode = false}) {
    Color baseColor = Color(int.parse(colorString, radix: 16) + 0xFF000000);
    if (isDarkMode) {
      baseColor = Color.fromARGB(
        (baseColor.a * 255.0).round() & 0xff,
        (baseColor.r * 0.8 * 255.0).round() & 0xff,
        (baseColor.g * 0.8 * 255.0).round() & 0xff,
        (baseColor.b * 0.8 * 255.0).round() & 0xff,
      );
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
                    final displayDate =
                        DateFormat('dd MMM').format(parsedDate);
                    return DropdownMenuItem<String>(
                      value: date,
                      child: Text(displayDate),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedDate = DateFormat('yyyy-MM-dd').parse(newValue!);
                      _fetchReservationsForSelectedDate();
                    });
                  },
                ),
                Spacer(),
                Text(
                  texts['title']!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () {
                    _fetchReservationsForSelectedDate();
                  },
                ),
                Spacer(),
              ],
            ),
            SizedBox(height: 16.0),
            if (selectedDateReservations.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  texts['noReservations']!,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.all(16.0),
                  height: 960.0,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.5),
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
                        Positioned.fill(
                          child: Column(
                            children: List.generate(15, (index) {
                              return Container(
                                height: 60.0,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color(0xFF74788D),
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 50.0,
                                      child: Text(
                                        '${(index + 6).toString().padLeft(2, '0')}:00',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.color,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        thickness: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
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
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => details
                                                    .ReservationDetailsPage(
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
                                                isDarkMode: Theme.of(context)
                                                        .brightness ==
                                                    Brightness
                                                        .dark,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.2),
                                                  spreadRadius: 2,
                                                  blurRadius: 4,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: reservation[
                                                        'duration_minutes'] >=
                                                    60
                                                ? Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        '${reservation['code']}',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyLarge
                                                                ?.color,
                                                            fontSize:
                                                                13
                                                            ),
                                                      ),
                                                      SizedBox(height: 4.0),
                                                      Text(
                                                        '${texts['room']!}: ${reservation['room']}, ${DateFormat('HH:mm').format(startTime)}',
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyMedium
                                                                ?.color,
                                                            fontSize:
                                                                10
                                                            ),
                                                      ),
                                                    ],
                                                  )
                                                : null,
                                          ),
                                        ),
                                      );
                                  }).toList(),
                                )
                              : SizedBox.shrink(),
                        ),
                        if (currentTimeOffset != null)
                          Positioned(
                            top: currentTimeOffset,
                            left:
                                0.0,
                            right:
                                0.0,
                            child: Container(
                              height: 2.0,
                              margin: const EdgeInsets.only(
                                  left: 50.0,
                                  right: 16.0),
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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

  @override
  void initState() {
    super.initState();
    _initializeDates();
    _fetchReservationsForSelectedDate();
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
          'http://127.0.0.1:8000/api/list_reservations/'),
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

  Color _parseColor(String colorString) {
    return Color(int.parse(colorString, radix: 16) + 0xFF000000);
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Moje Rezerwacje',
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
                    return DropdownMenuItem<String>(
                      value: date,
                      child: Text(date),
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
                  'Moje Rezerwacje',
                  style: TextStyle(
                    fontSize: 18,
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
                    color: Colors.white,
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
                                    bottom:
                                        BorderSide(color: Colors.grey[300]!),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 50.0,
                                      child: Text(
                                        '${(index + 6).toString().padLeft(2, '0')}:00',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: Colors.grey[300],
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
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 4.0),
                                        padding: const EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          color:
                                              _parseColor(reservation['color']),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.2),
                                              spreadRadius: 2,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: ListTile(
                                          title: Text(
                                            '${reservation['code']}', // Display reservation code
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors
                                                    .black), // Text color black
                                          ),
                                          subtitle: Text(
                                            'Sala: ${reservation['room']}, ${DateFormat('HH:mm').format(startTime)}',
                                            style: TextStyle(
                                                color: Colors
                                                    .black), // Text color black
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => details
                                                    .ReservationDetailsPage(
                                                        reservationData:
                                                            reservation),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                )
                              : Container(), // Removed the "No reservations found" text
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

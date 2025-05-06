// filepath: /c:/Users/coret/Documents/Flutter/pjatk_app/lib/home_page.dart
import 'package:flutter/material.dart';
import 'globals.dart' as globals;
import 'your_reserve.dart';
import 'new_reser_start.dart';
import 'main.dart';
import 'globals.dart';
import 'sidebar.dart';
import 'package:intl/intl.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    print(
        'Reservations in HomePage: ${globals.globalReservations}'); // Debugging: Print the reservations

    return BasePage(
      title: 'Home',
      addRightPadding: true,
      leftButtonAction: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SidebarPage()),
        );
      },
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nadchodzące',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: globals.globalReservations != null &&
                      globals.globalReservations!.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap:
                          true, // Ensure the ListView does not take the entire space
                      physics:
                          NeverScrollableScrollPhysics(), // Disable scrolling for the ListView
                      itemCount: globals.globalReservations!.length,
                      itemBuilder: (context, index) {
                        final reservation = globals.globalReservations![index];
                        return ListTile(
                          title: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '${reservation['name']}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18, // Adjust the font size
                                  ),
                                ),
                              ],
                            ),
                          ),
                          subtitle: Text(
                              'Sala: ${reservation['room']}, ${DateFormat('HH:mm').format(DateTime.parse(reservation['from_datetime']))}'),
                        );
                      },
                    )
                  : Text('Brak nadchodzących rezerwacji'),
            ),
            SizedBox(height: 24.0), // Space between the boxes
            // Your Reservations and New Reservation Box
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Twoje Rezerwacje',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MyReservationsPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFED1C24), // Button color
                          ),
                          child: Text(
                            'Wyświetl',
                            style: TextStyle(color: Colors.white), // Text color
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16.0), // Space between the boxes
                if (globalUserType != 'Student') // Check account type
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nowa Rezerwacja',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        NewReservationStartPage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color(0xFFED1C24), // Button color
                            ),
                            child: Text(
                              'Stwórz',
                              style:
                                  TextStyle(color: Colors.white), // Text color
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

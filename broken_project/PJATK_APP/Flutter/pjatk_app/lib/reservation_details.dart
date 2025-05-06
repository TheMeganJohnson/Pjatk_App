import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'globals.dart';
import 'main.dart'; // Import the custom AppBar

class ReservationDetailsPage extends StatelessWidget {
  final Map<String, dynamic> reservationData;

  const ReservationDetailsPage({Key? key, required this.reservationData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Parse the date and time from the reservation data
    DateTime date = DateTime.parse(reservationData['from_datetime']);

    // Calculate the time range for the button to be active
    DateTime startTime = date.subtract(Duration(minutes: 15));
    DateTime endTime =
        date.add(Duration(minutes: reservationData['duration_minutes']));

    bool isButtonActive =
        DateTime.now().isAfter(startTime) && DateTime.now().isBefore(endTime);

    return BasePage(
      title: 'Reservation Details',
      leftButtonAction: () {
        Navigator.pop(context);
      },
      leftButtonIcon: Icons.arrow_back,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${reservationData['name']}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  Text('Sala: ${reservationData['room']}'),
                  Text('Kod: ${reservationData['code']}'),
                  Text(
                      'Czas Trwania: ${reservationData['duration_minutes']} minutes'),
                  Text(
                      'Godzina Rozpoczęcia: ${DateFormat('HH:mm').format(DateTime.parse(reservationData['from_datetime']))}'),
                  Text('Grupa: ${reservationData['group']}'),
                  Text('Prowadzący: ${reservationData['user']}'),
                ],
              ),
            ),
            Spacer(),
            if (globalUserType !=
                'Student') // Check if the user is not a student
              Center(
                child: ElevatedButton(
                  onPressed: isButtonActive
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Otworzyłeś drzwi.')),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isButtonActive
                        ? Colors.red
                        : Colors
                            .grey, // Change button color based on active state
                    foregroundColor: Colors.white, // Change text color to white
                  ),
                  child: Text('Otwórz drzwi'),
                ),
              ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pjatk_app/home_page.dart';
import 'main.dart'; // Ensure main.dart is imported

class NewReservationFinishPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Rezerwacja Zakończona',
      leftButtonAction: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      },
      leftButtonIcon: Icons.home,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Rezerwacja zakończona pomyślnie!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                '\n Jak zostanie ona zatwierdzona przez administracje, będzie dostępna do podglądu w planie z detalami.',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

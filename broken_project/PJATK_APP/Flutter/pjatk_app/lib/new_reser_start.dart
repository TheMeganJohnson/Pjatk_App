import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'main.dart';
import 'globals.dart' as globals;
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
      title: 'Nowa Rezerwacja',
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
                      'General',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 16.0),
                    Text(
                      'Overview',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nazwa Rezerwacji',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: 'Kod Rezerwacji',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a code';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              Text(
                'Czas rezerwacji:',
                style: TextStyle(fontSize: 16),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dayController,
                      decoration: InputDecoration(
                        labelText: 'Dzień',
                        hintText: 'MM-dd',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a day';
                        }
                        try {
                          DateFormat('MM-dd').parse(value);
                        } catch (e) {
                          return 'Please enter a valid day';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: TextFormField(
                      controller: _startController,
                      decoration: InputDecoration(
                        labelText: 'Start',
                        hintText: 'HH:mm',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a start time';
                        }
                        try {
                          DateFormat('HH:mm').parse(value);
                        } catch (e) {
                          return 'Please enter a valid start time';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: TextFormField(
                      controller: _durationController,
                      decoration: InputDecoration(
                        labelText: 'Czas [min]',
                        hintText: 'minutes',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _roomController,
                      decoration: InputDecoration(
                        labelText: 'Sala',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a room';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: TextFormField(
                      controller: _groupController,
                      decoration: InputDecoration(
                        labelText: 'Grupa',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a group';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Center(
                child: SizedBox(
                  width: 110, // Set the desired width here
                  child: ElevatedButton(
                    onPressed: _navigateToEndPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFED1C24), // Button color
                    ),
                    child: Text(
                      '>',
                      style: TextStyle(color: Colors.white), // Text color
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

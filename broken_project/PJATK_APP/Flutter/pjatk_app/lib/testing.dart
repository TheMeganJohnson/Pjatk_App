import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'globals.dart' as globals;

class TestingPage extends StatefulWidget {
  @override
  _TestingPageState createState() => _TestingPageState();
}

class _TestingPageState extends State<TestingPage> {
  List<dynamic> _reservations = [];
  String _message = '';

  Future<void> _fetchReservations() async {
    print(
        'Fetching reservations for group: ${globals.globalGroup}'); // Debugging: Print the group value

    final response = await http.post(
      Uri.parse(
          'http://192.168.0.107:8000/api/list_reservations/'), // Update with your local IP address
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'group': globals.globalGroup ?? '',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          _reservations = data['reservations'];
          _message = 'Reservations fetched successfully';
        });
        // Print reservations to the console
        print('Reservations: $_reservations');
      } else {
        setState(() {
          _message =
              'Failed to fetch reservations: ${data['message']}'; // Debugging: Print the error message
        });
      }
    } else {
      setState(() {
        _message =
            'Failed to fetch reservations: ${response.reasonPhrase}'; // Debugging: Print the HTTP error
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchReservations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Testing Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(_message),
            Expanded(
              child: ListView.builder(
                itemCount: _reservations.length,
                itemBuilder: (context, index) {
                  final reservation = _reservations[index];
                  return ListTile(
                    title: Text(reservation['name']),
                    subtitle: Text(
                        'Room: ${reservation['room']}, Code: ${reservation['code']}'),
                    trailing: Text(
                        'Duration: ${reservation['duration_minutes']} mins'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

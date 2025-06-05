import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';

class TestingPage extends StatefulWidget {
  const TestingPage({super.key});

  @override
  State<TestingPage> createState() => _TestingPageState();
}

class _TestingPageState extends State<TestingPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _ldapResult = '';
  bool _isLoading = false;

  Future<void> testLdapConnection() async {
    setState(() {
      _isLoading = true;
      _ldapResult = '';
    });

    final String usernameRaw = _usernameController.text.trim();
    String? username;
    if (usernameRaw.contains('@')) {
      final parts = usernameRaw.split('@');
      if (parts.length == 2 && parts[1].toLowerCase() == 'pjwstk.edu.pl') {
        username = parts[0];
      } else {
        setState(() {
          _isLoading = false;
          _ldapResult = 'Incorrect credentials.';
        });
        return; // Do not attempt sending to server
      }
    } else {
      username = usernameRaw;
    }
    final String password = _passwordController.text;

    final Map<String, String> payload = {
      'username': username,
      'password': password,
    };
    print('Sending to backend: ${jsonEncode(payload)}'); // Debug print

    const String apiUrl = 'http://172.19.240.49:5000/api/ldap-auth';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _ldapResult =
              responseData['message'] ?? 'LDAP authentication successful!';
        });
      } else {
        setState(() {
          _ldapResult = 'LDAP authentication failed: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _ldapResult = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> resetFirstLoginFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_logged_in', false);
    await prefs.remove('user_pin');
    print('First login flag and PIN have been reset.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Testing Page')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed:
                    _isLoading
                        ? null
                        : () async {
                          await testLdapConnection();
                        },
                child:
                    _isLoading
                        ? CircularProgressIndicator()
                        : Text('Test LDAP Connection'),
              ),
              if (_ldapResult.isNotEmpty) ...[
                SizedBox(height: 12),
                Text(_ldapResult),
              ],
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  print(
                    'lastScannedQrContent: ${globals.lastScannedQrContent}',
                  );
                },
                child: Text('Print lastScannedQrContent'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await resetFirstLoginFlag();
                },
                child: Text('Reset First Login & PIN'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

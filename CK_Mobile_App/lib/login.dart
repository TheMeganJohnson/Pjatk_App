import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'network.dart';
import 'home_page.dart';
import 'globals.dart' as globals;
import 'main.dart';
import 'pin_setup.dart';
import 'pin_entry.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController loginController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final String _errorMessage = '';
  late Map<String, String> texts;

  bool _isLoading = false;

  final List<String> _serverUrls = [
    'https://ck.pjwstk.edu.pl/cyfrowe_klucze_app/login-userm/',
    'https://194.92.77.100:50343/cyfrowe_klucze_app/login-userm/',
  ];

  final List<String> _sha256Pins = [
    'fae88b1008028296cb00f16185f51cc2bc8ccb1ebe12f6763844eaa688fd6476',
    '4d71cf514624474d6e6bf7059ea8fd7b9c85b32b21cca5dd2c2aee592968fe96',
  ];

  @override
  void initState() {
    super.initState();
    _updateTexts();
    globals.languageNotifier.addListener(_onLanguageChange);
    _checkForPin();
  }

  Future<void> _checkForPin() async {
    final prefs = await SharedPreferences.getInstance();
    final pin = prefs.getString('user_pin');
    if (pin != null && pin.isNotEmpty) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PinEntryPage()),
      );
      if (result == true) {
        setState(() {
          _isLoading = true;
        });
        final serverUrl = await _getWorkingServerUrl();
        if (serverUrl == null) {
          setState(() {
            _isLoading = false;
          });
          _showErrorDialog(context, texts['noTrustedServer']!);
          return;
        }
        try {
          final dio = await NetworkHelper.getDio();
          final response = await dio.get(serverUrl);
          if (response.statusCode == 200) {
            final data = response.data is String ? jsonDecode(response.data) : response.data;
            final serverSessionKey = data['session_key'];
            final localSessionKey = prefs.getString('user_sessionKey') ?? globals.globalSessionKey;
            if (serverSessionKey == localSessionKey &&
                serverSessionKey != null &&
                serverSessionKey.isNotEmpty) {
              globals.globalFullName = prefs.getString('user_fullName') ?? '';
              globals.globalUserType = prefs.getString('user_userType') ?? '';
              globals.globalGroup = prefs.getString('user_group') ?? '';
              globals.globalEmail = prefs.getString('user_email') ?? '';
              globals.globalSessionKey = prefs.getString('user_sessionKey') ?? globals.globalSessionKey;

              bool reservationSuccess = true;
              try {
                await _fetchReservationsForToday().timeout(
                  const Duration(seconds: 10),
                  onTimeout: () async {
                    reservationSuccess = false;
                  },
                );
              } catch (_) {
                reservationSuccess = false;
              }
              if (!reservationSuccess) {
                setState(() {
                  _isLoading = false;
                });
                await _showErrorDialog(context, texts['gakkoTimeout']!);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
                return;
              }
              setState(() {
                _isLoading = false;
              });
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
              return;
            } else {
              setState(() {
                _isLoading = false;
              });
              await prefs.remove('user_pin');
              await prefs.remove('user_sessionKey');
              await prefs.setInt('pin_tries_left', 3);
              _showErrorDialog(context, texts['sessionKeyMismatch']!);
              return;
            }
          } else {
            setState(() {
              _isLoading = false;
            });
            await prefs.setInt('pin_tries_left', 3);
            _showErrorDialog(context, texts['failedVerifySession']!);
            return;
          }
        } catch (e) {
          setState(() {
            _isLoading = false;
          });

        }
      }
    }
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
      'login': 'Login',
      'password': 'Hasło',
      'loginButton': 'Zaloguj',
      'invalidLogin': 'Podaj poprawny login.',
      'invalidCredentials': 'Zły login lub hasło. Spróbuj ponownie.',
      'error': 'Błąd',
      'ok': 'OK',
      'noTrustedServer':
          'Nie znaleziono zaufanego serwera lub błąd certyfikatu.',
      'sessionKeyMismatch':
          'Klucz sesji nie pasuje. Zaloguj się ponownie i ustaw nowy PIN.',
      'failedVerifySession': 'Nie udało się zweryfikować klucza sesji.',
      'gakkoTimeout': 'Nie można połączyć z GAKKO.',
      'loading': 'Logowanie...',
    };

    final Map<String, String> englishTexts = {
      'login': 'Login',
      'password': 'Password',
      'loginButton': 'Log In',
      'invalidLogin': 'Enter a valid login.',
      'invalidCredentials': 'Invalid login or password. Try again.',
      'error': 'Error',
      'ok': 'OK',
      'noTrustedServer': 'No trusted server found or certificate mismatch.',
      'sessionKeyMismatch':
          'Session key mismatch. Please log in again and set a new PIN.',
      'failedVerifySession': 'Failed to verify session key.',
      'gakkoTimeout': 'Cannot connect to GAKKO.',
      'loading': 'Logging In...',
    };

    texts = globals.globalLanguagePolish == true ? polishTexts : englishTexts;
  }

  Future<String?> _getWorkingServerUrl() async {
    for (final url in _serverUrls) {
      try {
        final dio = await NetworkHelper.getDio(sha256Pins: _sha256Pins);
        final response = await dio.head(url).catchError((error) {
          return Response(
            requestOptions: RequestOptions(path: url),
            statusCode: 0,
          );
        });
        if (response.statusCode == 200) {
          return url;
        }
      } catch (e) {
      }
    }
    return null;
  }

  Future<void> _login(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    String login = loginController.text.trim();
    String password = passwordController.text;

    if (!_isValidLogin(login)) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(context, texts['invalidLogin']!);
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      await _showErrorDialog(
        context,
        texts['providePassword'] ?? (globals.globalLanguagePolish == true
            ? 'Podaj hasło.'
            : 'Please provide a password.'),
      );
      return;
    }

    final serverUrl = await _getWorkingServerUrl();
    if (serverUrl == null) {
      setState(() {
        _isLoading = false;
      });
      await _showErrorDialog(context, texts['noTrustedServer']!);
      return;
    }

    try {
      final dio = await NetworkHelper.getDio();
      final response = await dio.post(
        serverUrl,
        data: {'username': login, 'password': password},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        final data =
            response.data is String ? jsonDecode(response.data) : response.data;
        if (data['status'] == 'success') {
          globals.globalSessionKey = data['session_key'];
          globals.globalEmail = '$login@pjwstk.edu.pl';
          globals.globalFullName = login;
          if (RegExp(r'^s\d{5}$').hasMatch(login)) {
            globals.globalUserType = 'Student';
          } else {
            globals.globalUserType = 'Admin';
          }
          globals.globalGroup = 'GIs I.7';

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_fullName', globals.globalFullName ?? '');
          await prefs.setString('user_userType', globals.globalUserType ?? '');
          await prefs.setString('user_group', globals.globalGroup ?? '');
          await prefs.setString('user_email', globals.globalEmail ?? '');
          await prefs.setString(
            'user_sessionKey',
            globals.globalSessionKey ?? '',
          );

          try {
            await _fetchReservationsForToday().timeout(
              const Duration(seconds: 10),
              onTimeout: () async {
                setState(() {
                  _isLoading = false;
                });
                await _showErrorDialog(context, texts['gakkoTimeout']!);
                return;
              },
            );
          } catch (_) {
            setState(() {
              _isLoading = false;
            });
            await _showErrorDialog(context, texts['gakkoTimeout']!);
          }

          setState(() {
            _isLoading = false;
          });

          final pin = prefs.getString('user_pin');
          if (pin == null || pin.isEmpty) {
            final pinSet = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PinSetupPage()),
            );
            if (pinSet == true) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            }
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          }
        } else {
          setState(() {
            _isLoading = false;
          });
          await _showErrorDialog(context, texts['invalidCredentials']!);
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        await _showErrorDialog(context, texts['invalidCredentials']!);
      }
    } on DioException catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (e.response?.statusCode == 401) {
        await _showErrorDialog(context, texts['invalidCredentials']!);
      } else {
        await _showErrorDialog(context, '${texts['error']!}: $e');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      await _showErrorDialog(context, '${texts['error']!}: $e');
    }
  }

  Future<void> _fetchReservationsForToday() async {
    final response = await Dio().post(
      'https://${globals.pcIP}/api/list_reservations/',
      data: {
        'group': globals.globalGroup ?? '',
        'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      },
      options: Options(
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      ),
    );

    if (response.statusCode == 200) {
      final data =
          response.data is String ? jsonDecode(response.data) : response.data;
      if (data['status'] == 'success') {
        globals.globalReservations = data['reservations'];
      }
    }
  }

  bool _isValidLogin(String login) {
    return login.isNotEmpty && !login.contains('@');
  }

  Future<void> _showErrorDialog(BuildContext context, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(texts['error']!),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text(texts['ok']!),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop:  !_isLoading, 
      child: BasePage(
        title: 'Login',
        showLeftButton: false,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: _isLoading
                ? SizedBox(
                    height: 150,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(texts['loading']!),
                      ],
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 300,
                        child: TextField(
                          controller: loginController,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: texts['login'],
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      SizedBox(
                        width: 300,
                        child: TextField(
                          controller: passwordController,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: texts['password'],
                          ),
                          obscureText: true,
                        ),
                      ),
                      SizedBox(height: 16.0),
                      SizedBox(
                        width: 110,
                        child: ElevatedButton(
                          onPressed: () async {
                            await _login(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFED1C24),
                          ),
                          child: Text(
                            texts['loginButton']!,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            _errorMessage,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'globals.dart' as globals;
import 'main.dart';
import 'package:url_launcher/url_launcher.dart';

class ReservationDetailsPage extends StatefulWidget {
  final Map<String, dynamic> reservationData;

  const ReservationDetailsPage({super.key, required this.reservationData});

  @override
  _ReservationDetailsPageState createState() => _ReservationDetailsPageState();
}

class _ReservationDetailsPageState extends State<ReservationDetailsPage> {
  late Map<String, String> texts = {
    'title': '',
    'room': '',
    'code': '',
    'duration': '',
    'startTime': '',
    'group': '',
    'user': '',
    'yes': '',
    'no': '',
    'openDoor': '',
    'doorOpened': '',
  };

  String? scannedQrData;

  @override
  void initState() {
    super.initState();
    _updateTexts();
    globals.languageNotifier.addListener(_onLanguageChange);
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
      'title': 'Szczegóły Rezerwacji',
      'room': 'Sala',
      'code': 'Kod',
      'duration': 'Czas Trwania',
      'startTime': 'Godzina Rozpoczęcia',
      'group': 'Grupa',
      'user': 'Prowadzący',
      'yes': 'Tak',
      'no': 'Nie',
      'openDoor': 'Otwórz drzwi',
      'doorOpened': 'Drzwi zostały otwarte.',
      'wrongQr': 'Zły kod QR, drzwi nie zostały otwarte.',
    };

    final Map<String, String> englishTexts = {
      'title': 'Reservation Details',
      'room': 'Room',
      'code': 'Code',
      'duration': 'Duration',
      'startTime': 'Start Time',
      'group': 'Group',
      'user': 'User',
      'yes': 'Yes',
      'no': 'No',
      'openDoor': 'Open Door',
      'doorOpened': 'Door opened successfully.',
      'wrongQr': 'Wrong QR, doors are not open.',
    };

    texts = globals.globalLanguagePolish == true ? polishTexts : englishTexts;
  }

  Future<void> _scanQrAndShowDialog(BuildContext context) async {
    String? qrData;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Scan QR Code'),
          content: SizedBox(
            width: 300,
            height: 300,
            child: MobileScanner(
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                  qrData = barcodes.first.rawValue;
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
    if (qrData != null) {
      if (qrData == "QRCodeThatWorks") {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(texts['doorOpened'] ?? 'Door Opened Successfully'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
        return;
      }
      
      if (qrData == "https://www.youtube.com/watch?v=dQw4w9WgXcQ") {
        final url = Uri.parse(qrData!);
        try {
          await launchUrl(url, mode: LaunchMode.externalApplication);
          return;
        } catch (e) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Could not open YouTube'),
              content: SelectableText(qrData!),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(texts['wrongQr'] ?? 'Wrong QR, doors are not open.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
        globals.lastScannedQrContent = qrData;
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String raw = widget.reservationData['from_datetime'];
    String naive = raw.replaceFirst(RegExp(r'([Zz]|[+-]\d{2}:\d{2})$'), '');
    DateTime date = DateTime.parse(naive);
    DateTime startTime = date.subtract(Duration(minutes: 15));
    DateTime endTime = date.add(Duration(minutes: widget.reservationData['duration_minutes'] + 15));
    DateTime now = DateTime.now();
    bool isButtonActive = now.isAfter(startTime) && now.isBefore(endTime);

    return BasePage(
      title: texts['title'] ?? 'Reservation Details',
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
              width: double.infinity,
              constraints: BoxConstraints(
                maxHeight: 300.0,
              ),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
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
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.reservationData['name']}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '${texts['room'] ?? 'Room'}: ${widget.reservationData['room']}',
                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                  Text(
                    '${texts['code'] ?? 'Code'}: ${widget.reservationData['code']}',
                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                  Text(
                    '${texts['duration'] ?? 'Duration'}: ${widget.reservationData['duration_minutes']} minutes',
                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                  Text(
                    '${texts['startTime'] ?? 'Start Time'}: ${DateFormat('HH:mm').format(DateTime.parse(widget.reservationData['from_datetime']))}',
                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                  Text(
                    '${texts['group'] ?? 'Group'}: ${widget.reservationData['group']}',
                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                  Text(
                    '${texts['user'] ?? 'User'}: ${widget.reservationData['user']}',
                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                ],
              ),
            ),
            Spacer(),
            if (globals.globalUserType != 'Student')
              Center(
                child: ElevatedButton(
                  onPressed: isButtonActive
                      ? () => _scanQrAndShowDialog(context)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isButtonActive ? Color(0xFFED1C24) : Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(texts['openDoor'] ?? 'Open Door'),
                ),
              ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}

class QRViewPage extends StatelessWidget {
  const QRViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scan QR Code')),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
            Navigator.pop(context, barcodes.first.rawValue);
          }
        },
      ),
    );
  }
}

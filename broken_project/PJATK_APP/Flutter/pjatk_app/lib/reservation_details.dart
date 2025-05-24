import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'globals.dart' as globals;
import 'main.dart';
import 'package:url_launcher/url_launcher.dart';

class ReservationDetailsPage extends StatefulWidget {
  final Map<String, dynamic> reservationData;

  const ReservationDetailsPage({Key? key, required this.reservationData})
      : super(key: key);

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
    'verified': '',
    'yes': '',
    'no': '',
    'openDoor': '',
    'doorOpened': '',
  };

  String? scannedQrData;

  @override
  void initState() {
    super.initState();

    // Update texts based on the current language
    _updateTexts();

    // Listen to language changes
    globals.languageNotifier.addListener(_onLanguageChange);
  }

  @override
  void dispose() {
    // Remove the listener when the widget is disposed
    globals.languageNotifier.removeListener(_onLanguageChange);
    super.dispose();
  }

  void _onLanguageChange() {
    setState(() {
      // Update texts when the language changes
      _updateTexts();
    });
  }

  void _updateTexts() {
    // Define translated texts for both languages
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
      'doorOpened': 'Otworzyłeś drzwi.',
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
      'doorOpened': 'You opened the door.',
    };

    // Choose the appropriate texts based on the global language setting
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
                  Navigator.of(context).pop(); // Close scanner dialog
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
      // Check if it's a YouTube link
      final youtubeRegex = RegExp(r'^https?:\/\/(www\.)?(youtube\.com|youtu\.be)\/');
      if (youtubeRegex.hasMatch(qrData!)) {
        final url = Uri.parse(qrData!);
        try {
          await launchUrl(url, mode: LaunchMode.externalApplication);
          return;
        } catch (e) {
          // If launching fails, show the link in a dialog
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
        // Store in global for future use
        globals.lastScannedQrContent = qrData;
      }
      // Otherwise, show the dialog
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('QR Code Content'),
          content: SingleChildScrollView(
            child: SelectableText(
              qrData!,
              style: TextStyle(fontSize: 18),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Parse the date and time from the reservation data
    DateTime date = DateTime.parse(widget.reservationData['from_datetime']);

    // Calculate the time range for the button to be active (15 min before to 15 min after end)
    DateTime startTime = date.subtract(Duration(minutes: 15));
    DateTime endTime = date.add(Duration(minutes: widget.reservationData['duration_minutes'] + 15));

    bool isButtonActive =
        DateTime.now().toUtc().isAfter(startTime) && DateTime.now().toUtc().isBefore(endTime);

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
              width: double.infinity, // Take the full width of the screen
              constraints: BoxConstraints(
                maxHeight: 300.0, // Set a maximum height for the container
              ),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor, // Use theme's card color
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.2) // Thin white border for dark mode
                      : Colors.black.withOpacity(0.1), // Thin black border for light mode
                  width: 1.0, // Border thickness
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.05) // Light shadow for dark mode
                        : Colors.black.withOpacity(0.1), // Dark shadow for light mode
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: Offset(0, 4), // Slightly raised shadow
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Adjust height based on content
                children: [
                  Text(
                    '${widget.reservationData['name']}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color, // Use theme's text color
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

// Update QRViewPage to NOT pop to the reservation list if the dialog is open
class QRViewPage extends StatelessWidget {
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

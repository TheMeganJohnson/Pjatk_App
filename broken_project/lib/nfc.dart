import 'package:flutter/material.dart';
import 'nfc_emulator.dart';

class NFCPage extends StatefulWidget {
  const NFCPage({super.key});

  @override
  _NFCPageState createState() => _NFCPageState();
}

class _NFCPageState extends State<NFCPage> {
  final TextEditingController tokenController = TextEditingController();
  String receivedToken = '';

  @override
  void initState() {
    super.initState();
    NFCEmulator.tokenStream.listen((token) {
      setState(() {
        receivedToken = token;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NFC Token Emulator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Received Token: $receivedToken'),
            SizedBox(height: 16),
            TextField(
              controller: tokenController,
              decoration: InputDecoration(labelText: 'Enter Token'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                NFCEmulator.updateToken(tokenController.text);
              },
              child: Text('Update Token'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/services.dart';

class NFCEmulator {
  static const platform = MethodChannel('com.example.emulator_app/nfc');

  static Future<void> updateToken(String token) async {
    try {
      await platform.invokeMethod('updateToken', {'token': token});
    } on PlatformException catch (e) {
      print("Failed to update Token: '${e.message}'.");
    }
  }

  static const EventChannel tokenEventChannel =
      EventChannel('com.example.emulator_app/token');

  static Stream<String> get tokenStream {
    return tokenEventChannel
        .receiveBroadcastStream()
        .map((event) => event as String);
  }
}

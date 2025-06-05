// filepath: /c:/Users/coret/Documents/Flutter/pjatk_app/lib/globals.dart
library;

import 'package:flutter/material.dart';

String? globalEmail;
String? globalFullName;
String? globalUserType;
String? globalCardUID;
bool? globalAssigned;
bool? globalIsDarkMode;
List<String>? globalAssignedList;
String? globalSelectedDate;
List<dynamic>? globalReservations = [];
List<Map<String, dynamic>> todaysReservations = [];
String? globalGroup;
bool? globalLanguagePolish = true;
String? lastScannedQrContent;
String? pcIP = "192.168.0.94:8000";
String? globalSessionKey;

ValueNotifier<bool> languageNotifier = ValueNotifier(
  globalLanguagePolish ?? true,
);

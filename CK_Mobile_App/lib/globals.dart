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
bool? globalLanguagePolish;
String? lastScannedQrContent;
String? pcIP = "your-new-server-ip:8000";  // Replace with your actual server IP where Django is hosted
String? globalSessionKey;

ValueNotifier<bool> languageNotifier = ValueNotifier(
  globalLanguagePolish ?? true,
);

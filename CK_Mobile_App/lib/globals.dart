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
String? pcIP = "ck-mobile-backend.onrender.com";
String? globalSessionKey;

ValueNotifier<bool> languageNotifier = ValueNotifier(
  globalLanguagePolish ?? true,
);

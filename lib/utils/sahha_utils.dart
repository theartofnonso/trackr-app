
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sahha_flutter/sahha_flutter.dart';

import '../sahha_credentials.dart';
import '../shared_prefs.dart';

void configureSahha() {
  // Use custom values
  SahhaFlutter.configure(
    environment: SahhaEnvironment.sandbox,
  ) // Required - .sandbox for testing
      .then((success) => { debugPrint('Sahha configured: $success')})
      .catchError((error, stackTrace) => {debugPrint('Sahha configuration error: $error')});
}

void authenticateSahhaUser() {
  final userId = SharedPrefs().userId;
  SahhaFlutter.authenticate(appId: sahhaAppId, appSecret: sahhaAppSecret, externalId: userId)
      .then((success) => {debugPrint('Sahha user authenticated: $success')})
      .catchError((error, stackTrace) => {debugPrint('Sahha user authentication error: $error')});
}

int extractReadinessScore({required String jsonString}) {

  final List<dynamic> decoded = jsonDecode(jsonString);

  if (decoded.isEmpty || decoded.first is! Map) {
   return 0;
  }

  final Map<String, dynamic> first = decoded.first as Map<String, dynamic>;
  if (!first.containsKey('score')) {
    return 0;
  }
  final readiness = (first['score'] * 100) as int;
  return readiness;
}
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sahha_flutter/sahha_flutter.dart';

import '../sahha_credentials.dart';


final sahhaSensors = [
  SahhaSensor.steps,
  SahhaSensor.sleep,
  SahhaSensor.exercise,
  SahhaSensor.heart_rate_variability_rmssd,
  SahhaSensor.heart_rate_variability_sdnn,
  SahhaSensor.resting_heart_rate,
  SahhaSensor.heart_rate,
];


void configureSahha() {
  // Use custom values
  SahhaFlutter.configure(
    environment: kReleaseMode
        ? SahhaEnvironment.production : SahhaEnvironment.sandbox,
  ) // Required - .sandbox for testing
      .then((success) => {debugPrint('Sahha configured: $success')})
      .catchError((error, stackTrace) => {debugPrint('Sahha configuration error: $error')});
}

/// Authenticates the current user with the Sahha SDK and
/// returns `true` when the call succeeds *and* the SDK
/// reports the login as successful.
///
/// All failures (network, SDK, platform) are swallowed and
/// logged; the function then returns `false`.
Future<bool> authenticateSahhaUser({
  required String userId,
}) async {
  try {
    final isAuthenticated = await SahhaFlutter.authenticate(
      appId: kReleaseMode
          ? sahhaAppIdProd : sahhaAppIdDev,
      appSecret: kReleaseMode
          ? sahhaAppSecretProd: sahhaAppSecretDev,
      externalId: userId,
    );

    debugPrint('[Sahha] authenticate("$userId") → $isAuthenticated');
    return isAuthenticated;
  }

  // SDK / channel errors
  on PlatformException catch (e, st) {
    debugPrint('[Sahha] PlatformException • ${e.code}: ${e.message}');
    debugPrintStack(stackTrace: st);
  }

  // Anything else (network issues, bad config, etc.)
  catch (e, st) {
    debugPrint('[Sahha] unexpected error: $e');
    debugPrintStack(stackTrace: st);
  }

  return false;
}

void deAuthenticateSahhaUser() {
  SahhaFlutter.deauthenticate()
      .then((success) => {debugPrint('Sahha user deAuthenticated: $success')})
      .catchError((error, stackTrace) => {debugPrint('Sahha user deAuthentication error: $error')});
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
  final readiness = (first['score'] * 100 as num).toInt();
  return readiness;
}

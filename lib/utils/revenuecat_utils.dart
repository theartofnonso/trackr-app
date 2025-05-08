
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

const revenueCatAppleKey = "appl_noHyGNbNRfESNQVsIPMKDcuDkWn";

Future<void> configureRevenueCat() async {
  await Purchases.setLogLevel(LogLevel.debug);

  PurchasesConfiguration configuration;

  if (Platform.isAndroid) {
   // Not supporting Android at the moment
  } else if (Platform.isIOS) {
    configuration = PurchasesConfiguration(revenueCatAppleKey);
    Purchases.configure(configuration);
  }

}

Future<void> logInUserForAppPurchases({required String userId}) async {
  LogInResult result = await Purchases.logIn(userId);
  debugPrint('RevenueCat user logged in: ${result.customerInfo}');
}

Future<void> logOutUserForAppPurchases() async {
  await Purchases.logOut();
}

Future<PaywallResult> showPaywallIfNeeded() {
  return RevenueCatUI.presentPaywallIfNeeded("pro");
}
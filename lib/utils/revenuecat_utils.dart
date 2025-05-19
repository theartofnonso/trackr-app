import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

const revenueCatAppleKey = "appl_noHyGNbNRfESNQVsIPMKDcuDkWn";

Future<void> configureRevenueCat() async {
  if (Platform.isIOS) {
    await Purchases.setLogLevel(LogLevel.debug);

    final configuration = PurchasesConfiguration(revenueCatAppleKey);
    Purchases.configure(configuration);
  }
}

Future<void> logInUserForAppPurchases({required String userId}) async {
  if (Platform.isIOS) {
    LogInResult result = await Purchases.logIn(userId);
    debugPrint('RevenueCat user logged in: ${result.customerInfo}');
  }
}

Future<void> logOutUserForAppPurchases() async {
  if (Platform.isIOS) {
    await Purchases.logOut();
  }
}

Future<PaywallResult?> showPaywallIfNeeded() async {
  return Platform.isIOS ? RevenueCatUI.presentPaywallIfNeeded("pro") : null;
}

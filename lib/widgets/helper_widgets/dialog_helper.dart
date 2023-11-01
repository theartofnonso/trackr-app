import 'package:flutter/material.dart';

import '../../app_constants.dart';

void displayBottomSheet({required BuildContext context, required Widget child, double height = 216}) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => Container(
            height: height,
            padding: const EdgeInsets.only(top: 6.0),
            // The bottom margin is provided to align the popup above the system
            // navigation bar.
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            // Provide a background color for the popup.
            color: tealBlueLight,
            // Use a SafeArea widget to avoid system overlaps.
            child: SafeArea(
              top: false,
              child: child,
            ),
          ));
}

void showAlertDialog({required BuildContext context, required String message, required List<Widget> actions}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        icon: const Icon(Icons.info_outline),
        backgroundColor: tealBlueLighter,
        content: Text(
          message,
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        contentPadding: const EdgeInsets.only(top: 12, bottom: 10),
        actions: actions,
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(bottom: 8),
      );
    },
  );
}

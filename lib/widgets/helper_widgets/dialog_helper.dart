import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app_constants.dart';

void displayBottomSheet({required BuildContext context, required Widget child, double? height}) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => IntrinsicHeight(
        child: Container(
          height: height,
              padding: const EdgeInsets.only(top: 6.0),
              // The bottom margin is provided to align the popup above the system
              // navigation bar.
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              // Provide a background color for the popup.
              color: tealBlueDark,
              // Use a SafeArea widget to avoid system overlaps.
              child: SafeArea(
                top: false,
                child: child,
              ),
            ),
      ));
}

void showAlertDialog(
    {required BuildContext context,
    required String message,
    required void Function() leftAction,
    required void Function() rightAction,
    required String leftActionLabel,
    required String rightActionLabel,
    bool isLeftActionDestructive = false,
    bool isRightActionDestructive = false}) {
  final actions = <Widget>[
    TextButton(
      onPressed: leftAction,
      child: Text(leftActionLabel, style: GoogleFonts.lato(color: isLeftActionDestructive ? Colors.red : Colors.white)),
    ),
    TextButton(
      onPressed: rightAction,
      child:
          Text(rightActionLabel, style: GoogleFonts.lato(color: isRightActionDestructive ? Colors.red : Colors.white)),
    ),
  ];

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        icon: const Icon(Icons.info_outline),
        backgroundColor: tealBlueDark,
        content: Text(
          message,
          style: GoogleFonts.lato(fontSize: 14),
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

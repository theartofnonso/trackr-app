import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app_constants.dart';

void showSnackbar({required BuildContext context, required Widget icon, required String message}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: tealBlueLighter,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
      content: Row(
        children: [
          icon,
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
        ],
      )));
}

void displayBottomSheet({required BuildContext context, required Widget child, double? height}) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: height,
                margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                color: tealBlueLight,
                child: SafeArea(
                  child: child,
                ),
              ),
            ],
          ));
}

void showAlertDialogWithMultiActions(
    {required BuildContext context,
    required String message,
    required void Function() leftAction,
    required void Function() rightAction,
    required String leftActionLabel,
    required String rightActionLabel,
    bool isLeftActionDestructive = false,
    bool isRightActionDestructive = false}) {
  final alertActions = <Widget>[
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
        actions: alertActions,
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(bottom: 8),
      );
    },
  );
}

void showAlertDialogWithSingleAction(
    {required BuildContext context,
    required String message,
    required void Function() action,
    required String actionLabel}) {
  final alertActions = <Widget>[
    TextButton(
      onPressed: action,
      child: Text(actionLabel, style: GoogleFonts.lato(color: Colors.white)),
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
        actions: alertActions,
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(bottom: 8),
      );
    },
  );
}

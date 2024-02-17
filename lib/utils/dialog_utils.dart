import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../colors.dart';
import '../widgets/timers/hour_timer_picker.dart';
import '../widgets/timers/time_picker.dart';

void showSnackbar({required BuildContext context, required Widget icon, required String message}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.fixed,
      content: Row(
        children: [
          icon,
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.montserrat(
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
        ],
      )));
}

Future<void> displayBottomSheet(
    {required BuildContext context,
    required Widget child,
    double? height,
    EdgeInsets? padding,
    Color? color,
      enabledDrag = true,
    bool isDismissible = true, bool isScrollControlled = false}) {
  return showModalBottomSheet(
    isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enabledDrag,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: height,
                padding: padding,
                margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                color: color ?? sapphireLight,
                child: SafeArea(
                  child: child,
                ),
              ),
            ],
          ));
}

void displayTimePicker(
    {required BuildContext context,
    required CupertinoTimerPickerMode mode,
    required Duration initialDuration,
    required void Function(Duration duration) onChangedDuration}) {
  FocusScope.of(context).unfocus();
  displayBottomSheet(
      height: 240,
      context: context,
      color: sapphireDark,
      child: TimePicker(mode: mode, initialDuration: initialDuration, onDurationChanged: onChangedDuration));
}

void displayNotificationTimePicker(
    {required BuildContext context,
    required Duration initialDuration,
    required void Function(Duration duration) onChangedDuration}) {
  FocusScope.of(context).unfocus();
  displayBottomSheet(
      height: 240,
      context: context,
      color: sapphireDark,
      child: HourTimerPicker(
          initialDuration: initialDuration,
          onSelect: (Duration duration) {
            onChangedDuration(duration);
          }));
}

void showAlertDialogWithMultiActions(
    {required BuildContext context,
    required String message,
    required void Function() leftAction,
    required void Function() rightAction,
    required String leftActionLabel,
    required String rightActionLabel,
    bool isLeftActionDestructive = false,
    bool isRightActionDestructive = false, Color? rightActionColor}) {
  final alertActions = <Widget>[
    TextButton(
      onPressed: leftAction,
      child: Text(leftActionLabel,
          style: GoogleFonts.montserrat(color: isLeftActionDestructive ? Colors.red : Colors.white)),
    ),
    TextButton(
      onPressed: rightAction,
      child: Text(rightActionLabel,
          style: GoogleFonts.montserrat(
              color: isRightActionDestructive ? Colors.red : rightActionColor ?? Colors.white, fontWeight: FontWeight.w600)),
    ),
  ];

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: const BorderSide(
            color: sapphireLighter, // Border color
            width: 1.5, // Border width
          ),
        ),
        backgroundColor: sapphireDark.withOpacity(0.7),
        surfaceTintColor: sapphireDark.withOpacity(0.7),
        content: Text(
          message,
          style: GoogleFonts.montserrat(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        contentPadding: const EdgeInsets.only(top: 16, bottom: 10),
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
      child: Text(actionLabel, style: GoogleFonts.montserrat(color: Colors.white)),
    ),
  ];

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: const BorderSide(
            color: sapphireLighter, // Border color
            width: 1.5, // Border width
          ),
        ),
        backgroundColor: sapphireDark.withOpacity(0.7),
        surfaceTintColor: sapphireDark.withOpacity(0.7),
        content: Text(
          message,
          style: GoogleFonts.montserrat(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        contentPadding: const EdgeInsets.only(top: 16, bottom: 10),
        actions: alertActions,
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(bottom: 8),
      );
    },
  );
}

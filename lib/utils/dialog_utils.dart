import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../colors.dart';
import '../widgets/buttons/text_button_widget.dart';
import '../widgets/timers/hour_timer_picker.dart';
import '../widgets/timers/time_picker.dart';

void showSnackbar({required BuildContext context, required Widget icon, required String message}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: sapphireDark80,
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
    enabledDrag = true,
    bool isDismissible = true,
    bool isScrollControlled = false}) {
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
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      sapphireDark80,
                      sapphireDark,
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SafeArea(child: child),
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
      child: TimePicker(mode: mode, initialDuration: initialDuration, onDurationChanged: onChangedDuration));
}

void showHourTimerPicker(
    {required BuildContext context,
    required Duration initialDuration,
    required void Function(Duration duration) onChangedDuration}) {
  FocusScope.of(context).unfocus();
  displayBottomSheet(
      height: 240,
      context: context,
      child: HourTimerPicker(
          initialDuration: initialDuration,
          onSelect: (Duration duration) {
            onChangedDuration(duration);
          }));
}

Future<void> showBottomSheetWithNoAction(
    {required BuildContext context, required String title, required String description}) async {
  displayBottomSheet(
      context: context,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
            textAlign: TextAlign.start),
        Text(description,
            style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white),
            textAlign: TextAlign.start)
      ]));
}

void showBottomSheetWithMultiActions(
    {required BuildContext context,
    required String title,
    required String description,
    required void Function() leftAction,
    required void Function() rightAction,
    required String leftActionLabel,
    required String rightActionLabel,
    bool isLeftActionDestructive = false,
    bool isRightActionDestructive = true,
    Color? rightActionColor}) {
  displayBottomSheet(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title,
              style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
              textAlign: TextAlign.start),
          Text(description,
              style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white70),
              textAlign: TextAlign.start),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            CTextButton(
                onPressed: leftAction,
                label: leftActionLabel,
                textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white),
                buttonColor: Colors.transparent,
                buttonBorderColor: Colors.transparent),
            const SizedBox(width: 10),
            CTextButton(
                onPressed: rightAction,
                label: rightActionLabel,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
                buttonColor: vibrantGreen)
          ])
        ],
      ));
}

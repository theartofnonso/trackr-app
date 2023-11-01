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

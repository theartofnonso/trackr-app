import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';

import '../../helper_widgets/dialog_helper.dart';
import '../../time_picker.dart';

class TimerWidget extends StatelessWidget {
  final Duration duration;
  final void Function(Duration duration) onChangedDuration;

  const TimerWidget({super.key, required this.duration, required this.onChangedDuration});

  @override
  Widget build(BuildContext context) {
    return CTextButton(
      onPressed: () => _showRestIntervalTimePicker(context: context),
      label: duration.digitalTime(),
      textStyle: GoogleFonts.lato(fontSize: 15, color: Colors.white),
    );
  }

  void _showRestIntervalTimePicker({required BuildContext context}) {
    FocusScope.of(context).unfocus();
    displayBottomSheet(
        height: 216,
        context: context,
        child: TimePicker(
          mode: CupertinoTimerPickerMode.hms,
          initialDuration: duration,
          onSelect: (Duration duration) {
            Navigator.of(context).pop();
            onChangedDuration(duration);
          },
        ));
  }
}

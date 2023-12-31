import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';

import '../../helper_widgets/dialog_helper.dart';

class TimerWidget extends StatelessWidget {
  final Duration duration;
  final void Function(Duration duration) onChangedDuration;

  const TimerWidget({super.key, required this.duration, required this.onChangedDuration});

  @override
  Widget build(BuildContext context) {
    return CTextButton(
      onPressed: () => displayTimePicker(
          context: context,
          mode: CupertinoTimerPickerMode.hms,
          initialDuration: duration,
          onChangedDuration: onChangedDuration),
      label: duration.digitalTimeHMS(),
      textStyle: GoogleFonts.lato(fontSize: 15, color: Colors.white),
    );
  }
}

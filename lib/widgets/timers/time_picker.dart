import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../buttons/text_button_widget.dart';

class TimePicker extends StatefulWidget {
  final Duration? initialDuration;
  final void Function(Duration duration) onDurationChanged;
  final CupertinoTimerPickerMode mode;

  const TimePicker(
      {super.key,
      required this.onDurationChanged,
      required this.initialDuration,
      this.mode = CupertinoTimerPickerMode.ms});

  @override
  State<TimePicker> createState() => _TimerPickerState();
}

class _TimerPickerState extends State<TimePicker> {
  late Duration _duration;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 10),
        Flexible(
          child: Theme(
            data: ThemeData(
              brightness: Brightness.dark,
            ),
            child: CupertinoTimerPicker(
              initialTimerDuration: _duration,
              mode: widget.mode,
              // This is called when the user changes the timer's
              // duration.
              onTimerDurationChanged: (Duration newDuration) {
                setState(() => _duration = newDuration);
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        CTextButton(
            onPressed: () => widget.onDurationChanged(_duration),
            label: "Select time",
            buttonColor: Colors.transparent,
            buttonBorderColor: Colors.transparent,
            textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            padding: const EdgeInsets.all(10.0))
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    final previousDuration = widget.initialDuration;
    _duration = previousDuration ?? Duration.zero;
  }
}

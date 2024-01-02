import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../app_constants.dart';
import '../buttons/text_button_widget.dart';

class TimePicker extends StatefulWidget {
  final Duration? initialDuration;
  final void Function(Duration duration) onDurationChanged;
  final CupertinoTimerPickerMode mode;

  const TimePicker({super.key, required this.onDurationChanged, required this.initialDuration, this.mode = CupertinoTimerPickerMode.ms});

  @override
  State<TimePicker> createState() => _TimerPickerState();
}

class _TimerPickerState extends State<TimePicker> {
  late Duration _duration;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        CTextButton(onPressed: () => widget.onDurationChanged(_duration), label: "Select"),
        Flexible(
          child: Theme(
            data: ThemeData(
              brightness: Brightness.dark,
            ),
            child: CupertinoTimerPicker(
              initialTimerDuration: _duration,
              backgroundColor: tealBlueLight,
              mode: widget.mode,
              // This is called when the user changes the timer's
              // duration.
              onTimerDurationChanged: (Duration newDuration) {
                setState(() => _duration = newDuration);
              },
            ),
          ),
        ),
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

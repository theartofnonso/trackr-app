import 'package:flutter/cupertino.dart';
import 'package:tracker_app/colors.dart';

import '../buttons/opacity_button_widget.dart';

class TimePicker extends StatefulWidget {
  final Duration? initialDuration;
  final void Function(Duration duration) onDurationChanged;
  final CupertinoTimerPickerMode mode;

  const TimePicker(
      {super.key,
      required this.onDurationChanged, this.initialDuration,
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
        Expanded(
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
        const SizedBox(height: 10),
        OpacityButtonWidget(
            onPressed: () => widget.onDurationChanged(_duration),
            label: "Select duration",
            buttonColor: vibrantGreen,
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

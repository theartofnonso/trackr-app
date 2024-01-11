import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/extensions/duration_extension.dart';

import '../helper_widgets/dialog_helper.dart';
import 'routine_timer.dart';

class SetTimerWidget extends StatefulWidget {
  final bool enabled;
  final Duration duration;
  final void Function(Duration duration) onChangedDuration;

  const SetTimerWidget({super.key, required this.enabled, required this.duration, required this.onChangedDuration});

  @override
  State<SetTimerWidget> createState() => _SetTimerWidgetState();
}

class _SetTimerWidgetState extends State<SetTimerWidget> {
  DateTime? _startTime;

  bool _started = false;

  void _toggleTimer() {
    setState(() {
      _started = !_started;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.enabled)
          IconButton(
              onPressed: () {
                final startTime = _startTime;
                if (_started) {
                  if (startTime != null) {
                    widget.onChangedDuration(DateTime.now().difference(startTime));
                  }
                } else {
                  if (startTime == null) {
                    _startTime = DateTime.now();
                  } else {
                    _startTime = DateTime.now().subtract(widget.duration);
                  }
                }
                _toggleTimer();
              },
              icon: _started
                  ? const FaIcon(FontAwesomeIcons.pause, color: Colors.white70)
                  : const FaIcon(FontAwesomeIcons.play, color: Colors.white70)),
        _started && widget.enabled
            ? SizedBox(
                width: 70,
                child: Center(
                    child: RoutineTimer(
                  startTime: _startTime!,
                  digital: true,
                )))
            : GestureDetector(
                onTap: () => displayTimePicker(
                    context: context,
                    mode: CupertinoTimerPickerMode.hms,
                    initialDuration: widget.duration,
                    onChangedDuration: (Duration duration) {
                      Navigator.of(context).pop();
                      widget.onChangedDuration(duration);
                    }),
                child: Container(
                  width: 70,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: Text(widget.duration.hmsDigital(),
                        style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w500)),
                  ),
                ),
              )
      ],
    );
  }
}

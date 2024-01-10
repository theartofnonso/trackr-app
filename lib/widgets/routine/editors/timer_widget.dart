import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/extensions/duration_extension.dart';

import '../../helper_widgets/dialog_helper.dart';
import '../../timers/routine_timer.dart';

class InlineTimerWidget extends StatefulWidget {
  final bool stopped;
  final Duration duration;
  final void Function(Duration duration) onChangedDuration;

  const InlineTimerWidget({super.key, required this.stopped, required this.duration, required this.onChangedDuration});

  @override
  State<InlineTimerWidget> createState() => _InlineTimerWidgetState();
}

class _InlineTimerWidgetState extends State<InlineTimerWidget> {
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
        if(!widget.stopped)
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
        _started && !widget.stopped
            ? SizedBox(width: 65, child: RoutineTimer(startTime: _startTime!, digital: true))
            : GestureDetector(
                onTap: () => displayTimePicker(
                    context: context,
                    mode: CupertinoTimerPickerMode.hms,
                    initialDuration: widget.duration,
                    onChangedDuration: (Duration duration) {
                      Navigator.of(context).pop();
                      widget.onChangedDuration(duration);
                    }),
                child: SizedBox(
                  width: 65,
                  child: Text(widget.duration.hmsDigital(),
                      style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w500)),
                ),
              )
      ],
    );
  }
}

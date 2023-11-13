import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/utils/datetime_utils.dart';

import '../../../dtos/duration_set_dto.dart';
import '../../../screens/editor/routine_editor_screen.dart';
import '../../helper_widgets/dialog_helper.dart';
import '../../time_picker.dart';

class TimerWidget extends StatefulWidget {
  final DurationDto durationDto;
  final RoutineEditorType editorType;
  final void Function(Duration duration, bool cache) onChangedDuration;
  final void Function(int seconds) onTick;
  final bool enabled;

  const TimerWidget(
      {super.key, required this.durationDto,
        required this.editorType,
        required this.onChangedDuration,
        required this.onTick,
        required this.enabled});

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  Timer? _timer;
  int _elapsedSeconds = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.editorType == RoutineEditorType.log) _timerButton(),
        GestureDetector(
            onTap: () => _showRestIntervalTimePicker(context: context),
            child: Text(
              Duration(seconds: _elapsedSeconds).secondsOrMinutesOrHours(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ))
      ],
    );
  }

  Widget _timerButton() {
    final timer = _timer;
    return timer != null && timer.isActive
        ? IconButton(onPressed: _pauseTimer, icon: const Icon(Icons.pause_circle_outline_rounded, color: Colors.orange))
        : IconButton(onPressed: _startTimer, icon: const Icon(Icons.play_circle_outline_rounded, color: Colors.blue));
  }

  void _startTimer() {
    final timer = _timer;
    if (timer != null) {
      _elapsedSeconds = _elapsedSeconds;
    }

    if (widget.durationDto.cachedDuration > Duration.zero) {
      _elapsedSeconds = widget.durationDto.cachedDuration.inSeconds;
    } else {
      _elapsedSeconds = 0;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsedSeconds++;
      });
      widget.onTick(_elapsedSeconds);
    });
  }

  void _pauseTimer() {
    widget.onChangedDuration(Duration(seconds: _elapsedSeconds), true);
    setState(() {
      _timer?.cancel();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  void initState() {
    super.initState();
    _elapsedSeconds = widget.durationDto.cachedDuration > Duration.zero
        ? widget.durationDto.cachedDuration.inSeconds
        : widget.durationDto.duration.inSeconds;
  }

  @override
  void didUpdateWidget(TimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled) {
      _timer?.cancel();
    }
  }

  void _showRestIntervalTimePicker({required BuildContext context}) {
    FocusScope.of(context).unfocus();
    _pauseTimer();
    displayBottomSheet(
        context: context,
        child: TimePicker(
          mode: CupertinoTimerPickerMode.hms,
          initialDuration: widget.durationDto.duration,
          onSelect: (Duration duration) {
            Navigator.of(context).pop();
            setState(() {
              _elapsedSeconds = duration.inSeconds;
            });
            widget.onChangedDuration(Duration.zero, true);
            widget.onChangedDuration(duration, false);
          },
        ));
  }
}
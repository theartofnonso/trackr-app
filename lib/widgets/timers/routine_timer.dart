import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tracker_app/extensions/duration_extension.dart';

class RoutineTimer extends StatefulWidget {
  final DateTime startTime;
  final bool digital;
  final void Function(Duration duration)? onChangedDuration;
  final bool forceLightMode;

  const RoutineTimer(
      {super.key, required this.startTime, this.digital = false, this.onChangedDuration, this.forceLightMode = false});

  @override
  State<RoutineTimer> createState() => _RoutineTimerState();
}

class _RoutineTimerState extends State<RoutineTimer> {
  late Timer _timer;
  Duration _elapsedDuration = Duration.zero;

  @override
  Widget build(BuildContext context) {
    return Text(widget.digital ? _elapsedDuration.hmsDigital() : _elapsedDuration.hmsAnalog(),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: widget.forceLightMode ? Colors.white : null));
  }

  @override
  void initState() {
    super.initState();
    _elapsedDuration = DateTime.now().difference(widget.startTime);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final onChangedDuration = widget.onChangedDuration;
      if (onChangedDuration != null) {
        onChangedDuration(_elapsedDuration);
      }
      setState(() {
        _elapsedDuration = DateTime.now().difference(widget.startTime);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }
}

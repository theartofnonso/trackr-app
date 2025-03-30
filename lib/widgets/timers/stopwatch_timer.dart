import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tracker_app/extensions/duration_extension.dart';

class StopwatchTimer extends StatefulWidget {
  final DateTime startTime;
  final bool digital;
  final void Function(Duration duration)? onChangedDuration;
  final TextStyle? textStyle;
  final bool forceLightMode;

  const StopwatchTimer(
      {super.key, required this.startTime, this.digital = false, this.onChangedDuration, this.forceLightMode = false, this.textStyle});

  @override
  State<StopwatchTimer> createState() => _StopwatchTimerState();
}

class _StopwatchTimerState extends State<StopwatchTimer> {
  late Timer _timer;
  Duration _elapsedDuration = Duration.zero;

  @override
  Widget build(BuildContext context) {
    return Text(widget.digital ? _elapsedDuration.hmsDigital() : _elapsedDuration.hmsAnalog(),
        style: widget.textStyle ?? Theme.of(context).textTheme.bodyMedium?.copyWith(color: widget.forceLightMode ? Colors.white : null));
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
    _timer.cancel();
    super.dispose();
  }
}

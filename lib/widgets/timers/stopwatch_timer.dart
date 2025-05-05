import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tracker_app/extensions/duration_extension.dart';

class StopwatchTimer extends StatefulWidget {
  final DateTime startTime;
  final bool digital;
  final void Function(Duration duration)? onChangedDuration;
  final TextStyle? textStyle;
  final bool forceLightMode;
  final Duration? maxDuration;
  final Duration warningThreshold;
  final Color warningColor;
  final Color exceededColor;

  const StopwatchTimer({
    super.key,
    required this.startTime,
    this.digital = false,
    this.onChangedDuration,
    this.forceLightMode = false,
    this.textStyle,
    this.maxDuration,
    this.warningThreshold = const Duration(seconds: 10),
    this.warningColor = Colors.orange,
    this.exceededColor = Colors.red,
  });

  @override
  State<StopwatchTimer> createState() => _StopwatchTimerState();
}

class _StopwatchTimerState extends State<StopwatchTimer> {
  late Timer _timer;
  Duration _elapsedDuration = Duration.zero;

  @override
  Widget build(BuildContext context) {

    final maxDuration = widget.maxDuration;

    _elapsedDuration = DateTime.now().difference(widget.startTime);

    String elapsedDisplayText = widget.digital
        ? _elapsedDuration.hmsDigital()
        : _elapsedDuration.hmsAnalog();

    final Color? elapsedColor = widget.forceLightMode ? Colors.white : null;
    final TextStyle? elapsedStyle = (widget.textStyle ?? Theme.of(context).textTheme.bodyMedium)?.copyWith(color: elapsedColor);

    if (maxDuration != null && _elapsedDuration > maxDuration) {
      final Duration difference = _elapsedDuration - widget.maxDuration!;
      final bool isNegative = difference.isNegative;
      final Duration absoluteDifference = difference.abs();
      final String differenceTimeString = widget.digital
          ? absoluteDifference.hmsDigital()
          : absoluteDifference.hmsAnalog();
      final String differenceDisplayText = '${isNegative ? '-' : '+'}$differenceTimeString';

      Color? differenceColor;
      if (_elapsedDuration >= widget.maxDuration!) {
        differenceColor = widget.exceededColor;
      } else {
        final Duration remaining = widget.maxDuration! - _elapsedDuration;
        if (remaining <= widget.warningThreshold) {
          differenceColor = widget.warningColor;
        }
      }

      final Color? finalDifferenceColor = differenceColor ?? (widget.forceLightMode ? Colors.white : null);
      final TextStyle? differenceStyle = (widget.textStyle ?? Theme.of(context).textTheme.bodySmall)?.copyWith(color: finalDifferenceColor, fontSize: 18, fontWeight: FontWeight.w500);

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(elapsedDisplayText, style: elapsedStyle),
          Text(differenceDisplayText, style: differenceStyle),
        ],
      );
    } else {
      return Text(elapsedDisplayText, style: elapsedStyle);
    }
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
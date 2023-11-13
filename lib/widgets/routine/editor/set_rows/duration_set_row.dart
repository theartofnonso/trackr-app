import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/dtos/duration_dto.dart';
import 'package:tracker_app/utils/datetime_utils.dart';

import '../../../../dtos/set_dto.dart';
import '../../../../screens/editor/routine_editor_screen.dart';
import '../../../helper_widgets/dialog_helper.dart';
import '../../../time_picker.dart';
import '../set_type_icon.dart';

class DurationSetRow extends StatefulWidget {
  final int index;
  final int workingIndex;
  final SetDto setDto;
  final SetDto? pastSetDto;
  final RoutineEditorType editorType;
  final void Function() onTapCheck;
  final void Function() onRemoved;
  final void Function(SetType type) onChangedType;
  final void Function(Duration duration, bool cache) onChangedDuration;

  const DurationSetRow(
      {super.key,
      required this.index,
      required this.workingIndex,
      required this.setDto,
      this.pastSetDto,
      required this.editorType,
      required this.onTapCheck,
      required this.onRemoved,
      required this.onChangedType,
      required this.onChangedDuration});

  @override
  State<DurationSetRow> createState() => _DurationSetRowState();
}

class _DurationSetRowState extends State<DurationSetRow> {
  int _elapsedTime = 0;
  bool _isStopped = false;

  @override
  Widget build(BuildContext context) {
    final previousSetDto = widget.pastSetDto as DurationDto?;

    return Table(
      columnWidths: widget.editorType == RoutineEditorType.edit
          ? <int, TableColumnWidth>{
              0: const FixedColumnWidth(30),
              1: const FlexColumnWidth(2),
              2: const FlexColumnWidth(3),
            }
          : <int, TableColumnWidth>{
              0: const FixedColumnWidth(30),
              1: const FlexColumnWidth(2),
              2: const FlexColumnWidth(2),
              3: const FlexColumnWidth(1),
            },
      children: [
        TableRow(children: [
          TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: SetTypeIcon(
                type: widget.setDto.type,
                label: widget.workingIndex,
                onSelectSetType: widget.onChangedType,
                onRemoveSet: widget.onRemoved,
              )),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: previousSetDto != null
                ? Text(
                    previousSetDto.duration.secondsOrMinutesOrHours(),
                    style: GoogleFonts.lato(
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  )
                : Text("-", textAlign: TextAlign.center, style: GoogleFonts.lato(color: Colors.white70)),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: _IntervalTimer(
              editorType: widget.editorType,
              durationDto: (widget.setDto as DurationDto),
              onChangedDuration: (Duration duration, bool cache) => widget.onChangedDuration(duration, cache),
              onTick: (int seconds) {
                setState(() {
                  _elapsedTime = seconds;
                });
              },
              enabled: _isStopped,
            ),
          ),
          if (widget.editorType == RoutineEditorType.log)
            TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: GestureDetector(
                  onTap: () {
                    print(_elapsedTime);
                    widget.onChangedDuration(Duration(seconds: _elapsedTime), false);
                    widget.onTapCheck();
                    _isStopped = true;
                  },
                  child: widget.setDto.checked
                      ? const Icon(Icons.check_box_rounded, color: Colors.green)
                      : const Icon(Icons.check_box_rounded, color: Colors.grey),
                ))
        ])
      ],
    );
  }
}

class _IntervalTimer extends StatefulWidget {
  final DurationDto durationDto;
  final RoutineEditorType editorType;
  final void Function(Duration duration, bool cache) onChangedDuration;
  final void Function(int seconds) onTick;
  final bool enabled;

  const _IntervalTimer(
      {required this.durationDto,
      required this.editorType,
      required this.onChangedDuration,
      required this.onTick,
      required this.enabled});

  @override
  State<_IntervalTimer> createState() => _IntervalTimerState();
}

class _IntervalTimerState extends State<_IntervalTimer> {
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
  void didUpdateWidget(_IntervalTimer oldWidget) {
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

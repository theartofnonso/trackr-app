import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/dtos/duration_dto.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import 'package:tracker_app/widgets/routine/editor/set_widgets/set_widget.dart';

import '../../../../dtos/set_dto.dart';
import '../../../../screens/editor/routine_editor_screen.dart';
import '../../../helper_widgets/dialog_helper.dart';
import '../../../time_picker.dart';
import '../set_type_icon.dart';

class DurationWidget extends SetWidget {
  const DurationWidget(
      {Key? key,
      required int index,
      required int workingIndex,
      required SetDto setDto,
      SetDto? pastSetDto,
      RoutineEditorType editorType = RoutineEditorType.edit,
      required VoidCallback onTapCheck,
      required VoidCallback onRemoved,
      required void Function(Duration duration, bool cache) onChangedDuration,
      required void Function(SetType type) onChangedType})
      : super(
            key: key,
            index: index,
            workingIndex: workingIndex,
            setDto: setDto,
            pastSetDto: pastSetDto,
            editorType: editorType,
            onTapCheck: onTapCheck,
            onRemoved: onRemoved,
            onChangedType: onChangedType,
            onChangedDuration: onChangedDuration);

  @override
  Widget build(BuildContext context) {
    final previousSetDto = pastSetDto as DurationDto?;

    return Table(
      columnWidths: const <int, TableColumnWidth>{
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(3),
        3: FlexColumnWidth(1),
      },
      children: [
        TableRow(children: [
          TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: SetTypeIcon(
                type: setDto.type,
                label: workingIndex,
                onSelectSetType: onChangedType,
                onRemoveSet: onRemoved,
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
                durationDto: (setDto as DurationDto),
                onChangedDuration: (Duration duration, bool cache) {
                  final callback = onChangedDuration;
                  if (callback != null) {
                    callback(duration, cache);
                  }
                }),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: editorType == RoutineEditorType.log
                ? GestureDetector(
                    onTap: onTapCheck,
                    child: setDto.checked
                        ? const Icon(Icons.check_box_rounded, color: Colors.green)
                        : const Icon(Icons.check_box_rounded, color: Colors.grey),
                  )
                : const SizedBox.shrink(),
          )
        ])
      ],
    );
  }
}

class _IntervalTimer extends StatefulWidget {
  final DurationDto durationDto;
  final void Function(Duration duration, bool cache) onChangedDuration;

  const _IntervalTimer({required this.durationDto, required this.onChangedDuration});

  @override
  State<_IntervalTimer> createState() => _IntervalTimerState();
}

class _IntervalTimerState extends State<_IntervalTimer> {
  Timer? _timer;
  int _elapsedSeconds = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _timerButton(),
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

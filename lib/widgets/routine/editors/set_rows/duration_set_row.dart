import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/set_dtos/duration_set_dto.dart';
import 'package:tracker_app/extensions/duration_extension.dart';

import '../../../../enums/routine_editor_type_enums.dart';
import '../../../../utils/dialog_utils.dart';
import '../../../timers/routine_timer.dart';
import '../set_check_button.dart';
import '../set_delete_button.dart';

class DurationSetRow extends StatelessWidget {
  final DurationSetDto setDto;
  final RoutineEditorMode editorType;
  final VoidCallback onRemoved;
  final VoidCallback onCheck;
  final DateTime startTime;
  final void Function(Duration duration, {bool checked}) onCheckAndUpdateDuration;
  final void Function(Duration duration) onupdateDuration;

  const DurationSetRow({
    super.key,
    required this.setDto,
    required this.editorType,
    required this.onRemoved,
    required this.onCheck,
    required this.onCheckAndUpdateDuration,
    required this.onupdateDuration,
    required this.startTime,
  });

  void _toggleTimer() {
    onCheckAndUpdateDuration(DateTime.now().difference(startTime), checked: true);
  }

  void _selectTime({required BuildContext context}) {
    displayTimePicker(
        context: context,
        initialDuration: setDto.duration,
        mode: CupertinoTimerPickerMode.hms,
        onChangedDuration: (Duration duration) {
          Navigator.of(context).pop();
          onupdateDuration(duration);
        });
  }

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return Table(
      border:
          TableBorder.all(color: isDarkMode ? Colors.white10 : Colors.black38, borderRadius: BorderRadius.circular(5)),
      columnWidths: editorType == RoutineEditorMode.edit
          ? <int, TableColumnWidth>{
              0: const FixedColumnWidth(50),
              1: const FlexColumnWidth(1),
            }
          : <int, TableColumnWidth>{
              0: const FixedColumnWidth(50),
              1: const FlexColumnWidth(1),
              2: const FixedColumnWidth(60),
            },
      children: [
        TableRow(children: [
          TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Center(child: SetDeleteButton(onDelete: onRemoved))),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: GestureDetector(
              onTap: () => _selectTime(context: context),
              child: SizedBox(
                height: 50,
                child: Center(
                  child: editorType == RoutineEditorMode.edit || setDto.checked
                      ? Text(setDto.duration.hmsDigital(), style: Theme.of(context).textTheme.bodyMedium)
                      : RoutineTimer(
                          startTime: startTime,
                          digital: true,
                          onChangedDuration: (Duration duration) => onCheckAndUpdateDuration(duration)),
                ),
              ),
            ),
          ),
          if (editorType == RoutineEditorMode.log)
            TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: SetCheckButton(setDto: setDto, onCheck: _toggleTimer))
        ])
      ],
    );
  }
}

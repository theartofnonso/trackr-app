import 'package:flutter/material.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/widgets/routine/editors/set_rows/set_row.dart';

import '../../../../app_constants.dart';
import '../../../../enums/routine_editor_type_enums.dart';
import '../../../../utils/general_utils.dart';
import '../set_check_button.dart';
import '../set_delete_button.dart';
import '../textfields/double_textfield.dart';
import '../timer_widget.dart';

class DurationDistanceSetRow extends SetRow {
  final void Function(Duration duration) onChangedDuration;
  final void Function(double distance) onChangedDistance;
  final (TextEditingController, TextEditingController) controllers;

  const DurationDistanceSetRow(
      {super.key,
      required this.controllers,
      required this.onChangedDuration,
      required this.onChangedDistance,
      required super.setDto,
      required super.editorType,
      required super.onRemoved,
      required super.onCheck});

  @override
  Widget build(BuildContext context) {
    Duration duration = Duration(milliseconds: setDto.value1.toInt());
    double distance = isDefaultDistanceUnit()
        ? setDto.value2.toDouble()
        : toKM(setDto.value2.toDouble(), type: ExerciseType.durationAndDistance);

    return Table(
      border: TableBorder.all(color: tealBlueLighter, borderRadius: BorderRadius.circular(5)),
      columnWidths: editorType == RoutineEditorMode.edit
          ? <int, TableColumnWidth>{
              0: const FixedColumnWidth(50),
              1: const FlexColumnWidth(1),
              2: const FlexColumnWidth(1),
            }
          : <int, TableColumnWidth>{
              0: const FixedColumnWidth(50),
              1: const FlexColumnWidth(1),
              2: const FlexColumnWidth(1),
              3: const FixedColumnWidth(60),
            },
      children: [
        TableRow(children: [
          TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle, child: SetDeleteButton(onDelete: super.onRemoved)),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: DoubleTextField(
              value: distance,
              onChanged: (value) {
                final conversion = _convertDistance(value: value);
                onChangedDistance(conversion);
              },
              controller: controllers.$2,
            ),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: TimerWidget(
              duration: duration,
              onChangedDuration: (Duration duration) => onChangedDuration(duration),
            ),
          ),
          if (editorType == RoutineEditorMode.log)
            TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: SetCheckButton(setDto: setDto, onCheck: onCheck))
        ])
      ],
    );
  }

  double _convertDistance({required double value}) {
    return isDefaultDistanceUnit() ? value : toMI(value, type: ExerciseType.durationAndDistance);
  }
}

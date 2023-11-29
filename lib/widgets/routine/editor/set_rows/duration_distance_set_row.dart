import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/widgets/routine/editor/set_rows/set_row.dart';

import '../../../../app_constants.dart';
import '../../../../screens/editors/routine_editor_screen.dart';
import '../../../../utils/general_utils.dart';
import '../set_check_button.dart';
import '../set_type_icon.dart';
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
      required super.index,
      required super.setTypeIndex,
      required super.procedureId,
      required super.setDto,
      required super.pastSetDto,
      required super.editorType,
      required super.onRemoved,
      required super.onChangedType,
      required super.onCheck});

  @override
  Widget build(BuildContext context) {
    final previousSetDto = pastSetDto;

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
              3: const FlexColumnWidth(1),
            }
          : <int, TableColumnWidth>{
              0: const FixedColumnWidth(50),
              1: const FlexColumnWidth(3),
              2: const FlexColumnWidth(2),
              3: const FlexColumnWidth(3),
              4: const FixedColumnWidth(40),
            },
      children: [
        TableRow(children: [
          TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: SetTypeIcon(
                label: setDto.id,
                onSelectSetType: onChangedType,
                onRemoveSet: onRemoved,
                type: setDto.type,
              )),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: previousSetDto != null
                ? Text(
                    "${previousSetDto.value2.toDouble()}${distanceLabel(type: ExerciseType.durationAndDistance)} \n ${Duration(milliseconds: previousSetDto.value1.toInt()).digitalTime()}",
                    style: GoogleFonts.lato(
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  )
                : Text("-", textAlign: TextAlign.center, style: GoogleFonts.lato(color: Colors.white70)),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: DoubleTextField(
              value: distance,
              onChanged: (value) {
                final conversion = _convertDistance(value: value);
                onChangedDistance(conversion);
              },
              controller: controllers.$1,
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

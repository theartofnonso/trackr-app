import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/widgets/routine/editor/set_rows/set_row.dart';
import 'package:tracker_app/widgets/routine/editor/textfields/double_textfield.dart';

import '../../../../enums/exercise_type_enums.dart';
import '../../../../screens/editors/routine_editor_screen.dart';
import '../../../../utils/general_utils.dart';
import '../set_check_button.dart';
import '../set_type_icon.dart';

class WeightDistanceSetRow extends SetRow {
  final void Function(double value) onChangedWeight;
  final void Function(double value) onChangedDistance;
  final (TextEditingController, TextEditingController) controllers;

  const WeightDistanceSetRow(
      {super.key,
      required this.controllers,
      required this.onChangedDistance,
      required this.onChangedWeight,
      required super.index,
      required super.setTypeIndex,
      required super.procedureId,
      required super.setDto,
      required super.pastSetDto,
      required super.editorType,
      required super.onChangedType,
      required super.onRemoved,
      required super.onCheck});

  @override
  Widget build(BuildContext context) {
    final previousSetDto = pastSetDto;

    double weight = 0;
    double distance = 0;

    if (previousSetDto != null) {
      weight = isDefaultWeightUnit() ? previousSetDto.value1.toDouble() : toLbs(previousSetDto.value1.toDouble());
      distance = previousSetDto.value2.toDouble();
    } else {
      weight = isDefaultWeightUnit() ? setDto.value1.toDouble() : toLbs(setDto.value1.toDouble());
      distance = setDto.value2.toDouble();
    }

    distance = isDefaultDistanceUnit()
        ? setDto.value2.toDouble()
        : toKM(setDto.value2.toDouble(), type: ExerciseType.weightAndDistance);

    return Table(
      columnWidths: editorType == RoutineEditorMode.edit
          ? <int, TableColumnWidth>{
              0: const FixedColumnWidth(35),
              1: const FlexColumnWidth(1),
              2: const FlexColumnWidth(1),
              3: const FlexColumnWidth(1),
            }
          : <int, TableColumnWidth>{
              0: const FixedColumnWidth(35),
              1: const FlexColumnWidth(2),
              2: const FlexColumnWidth(2),
              3: const FlexColumnWidth(2),
              4: const FlexColumnWidth(1),
            },
      children: [
        TableRow(children: [
          TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: SetTypeIcon(
                label: "${setDto.type.label}${setTypeIndex + 1}",
                onSelectSetType: onChangedType,
                onRemoveSet: onRemoved,
                type: setDto.type,
              )),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: previousSetDto != null
                ? Text(
                    "${previousSetDto.value1.toDouble()}${weightLabel()}\n${previousSetDto.value2.toDouble()}${distanceLabel(type: ExerciseType.weightAndDistance)}",
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
              value: weight,
              onChanged: (value) {
                final conversion = _convertWeight(value: value);
                onChangedWeight(conversion);
              },
              controller: controllers.$1,
            ),
          ),
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
          if (editorType == RoutineEditorMode.log)
            TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: SetCheckButton(setDto: setDto, onCheck: onCheck))
        ])
      ],
    );
  }

  double _convertWeight({required double value}) {
    return isDefaultWeightUnit() ? value : toKg(value);
  }

  double _convertDistance({required double value}) {
    return isDefaultDistanceUnit() ? value : toMI(value, type: ExerciseType.weightAndDistance);
  }
}

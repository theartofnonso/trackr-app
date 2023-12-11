import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/widgets/routine/editors/set_rows/set_row.dart';
import 'package:tracker_app/widgets/routine/editors/textfields/double_textfield.dart';

import '../../../../app_constants.dart';
import '../../../../enums/exercise_type_enums.dart';
import '../../../../enums/routine_editor_type_enums.dart';
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
      required super.setDto,
      required super.pastSetDto,
      required super.editorType,
      required super.onChangedType,
      required super.onRemoved,
      required super.onCheck});

  @override
  Widget build(BuildContext context) {
    final previousSetDto = pastSetDto;

    double weight = isDefaultWeightUnit() ? setDto.value1.toDouble() : toLbs(setDto.value1.toDouble());
    double distance = isDefaultDistanceUnit()
        ? setDto.value2.toDouble()
        : toKM(setDto.value2.toDouble(), type: ExerciseType.weightAndDistance);

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
              1: const FlexColumnWidth(1),
              2: const FlexColumnWidth(1),
              3: const FlexColumnWidth(1),
              4: const FixedColumnWidth(50),
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
              pastValue: previousSetDto?.value1.toDouble(),
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
              pastValue: previousSetDto?.value2.toDouble(),
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
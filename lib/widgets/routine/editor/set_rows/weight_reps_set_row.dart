import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/widgets/routine/editor/set_rows/set_row.dart';
import 'package:tracker_app/widgets/routine/editor/textfields/double_textfield.dart';
import 'package:tracker_app/widgets/routine/editor/textfields/int_textfield.dart';

import '../../../../screens/editors/routine_editor_screen.dart';
import '../../../../utils/general_utils.dart';
import '../set_check_button.dart';
import '../set_type_icon.dart';

class WeightRepsSetRow extends SetRow {
  final void Function(int value) onChangedReps;
  final void Function(double value) onChangedWeight;
  final (TextEditingController, TextEditingController) controllers;

  const WeightRepsSetRow(
      {super.key,
      required this.controllers,
      required this.onChangedReps,
      required this.onChangedWeight,
      required super.index,
      required super.setTypeIndex,
      required super.procedureId,
      required super.setDto,
      required super.pastSetDto,
      required super.editorType,
      required super.onChangedType,
      required super.onRemoved,
      required super.onCheck,
      required super.onUpdateSetWithPastSet});

  @override
  Widget build(BuildContext context) {
    final previousSetDto = pastSetDto;

    double weight = 0;
    int reps = 0;

    if (previousSetDto != null) {
      weight = isDefaultWeightUnit() ? previousSetDto.value1.toDouble() : toLbs(previousSetDto.value1.toDouble());
      reps = previousSetDto.value2.toInt();
      onUpdateSetWithPastSet(previousSetDto.copyWith(checked: setDto.checked));
    } else {
      weight = isDefaultWeightUnit() ? setDto.value1.toDouble() : toLbs(setDto.value1.toDouble());
      reps = setDto.value2.toInt();
    }

    return Table(
      border: TableBorder.all(color: tealBlueLighter, borderRadius: BorderRadius.circular(5)),
      columnWidths: editorType == RoutineEditorMode.edit
          ? <int, TableColumnWidth>{
              0: const FixedColumnWidth(50),
              1: const FlexColumnWidth(3),
              2: const FlexColumnWidth(2),
              3: const FlexColumnWidth(2),
            }
          : <int, TableColumnWidth>{
              0: const FixedColumnWidth(50),
              1: const FlexColumnWidth(3),
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
                    "${previousSetDto.value1.toDouble()}${weightLabel()} x ${previousSetDto.value2.toInt()}",
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
            child: IntTextField(
              value: reps,
              onChanged: onChangedReps,
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
}

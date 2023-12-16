import 'package:flutter/material.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/widgets/routine/editors/set_rows/set_row.dart';
import 'package:tracker_app/widgets/routine/editors/textfields/double_textfield.dart';
import 'package:tracker_app/widgets/routine/editors/textfields/int_textfield.dart';

import '../../../../enums/routine_editor_type_enums.dart';
import '../../../../utils/general_utils.dart';
import '../set_check_button.dart';
import '../set_delete_button.dart';

class WeightRepsSetRow extends SetRow {
  final void Function(int value) onChangedReps;
  final void Function(double value) onChangedWeight;
  final (TextEditingController, TextEditingController) controllers;

  const WeightRepsSetRow(
      {super.key,
      required this.controllers,
      required this.onChangedReps,
      required this.onChangedWeight,
      required super.setDto,
      required super.editorType,
      required super.onRemoved,
      required super.onCheck});

  @override
  Widget build(BuildContext context) {
    double weight = isDefaultWeightUnit() ? setDto.value1.toDouble() : toLbs(setDto.value1.toDouble());
    int reps = setDto.value2.toInt();

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

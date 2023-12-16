import 'package:flutter/material.dart';
import 'package:tracker_app/widgets/routine/editors/set_rows/set_row.dart';
import 'package:tracker_app/widgets/routine/editors/textfields/int_textfield.dart';

import '../../../../app_constants.dart';
import '../../../../enums/routine_editor_type_enums.dart';
import '../set_check_button.dart';
import '../set_delete_button.dart';

class RepsSetRow extends SetRow {
  final (TextEditingController, TextEditingController) controllers;
  final void Function(num value) onChangedReps;

  const RepsSetRow(
      {super.key,
      required this.controllers,
      required this.onChangedReps,
      required super.setDto,
      required super.editorType,
      required super.onRemoved,
      required super.onCheck});

  @override
  Widget build(BuildContext context) {
    int reps = setDto.value2.toInt();

    return Table(
      border: TableBorder.all(color: tealBlueLighter, borderRadius: BorderRadius.circular(5)),
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
              verticalAlignment: TableCellVerticalAlignment.middle, child: SetDeleteButton(onDelete: super.onRemoved)),
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
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/widgets/routine/editor/set_rows/set_row.dart';
import 'package:tracker_app/widgets/routine/editor/textfields/set_double_textfield.dart';
import 'package:tracker_app/widgets/routine/editor/textfields/set_int_textfield.dart';

import '../../../../screens/editor/routine_editor_screen.dart';
import '../../../../utils/general_utils.dart';
import '../set_check_button.dart';
import '../set_type_icon.dart';

class WeightedSetRow extends SetRow {
  final void Function(int value) onChangedReps;
  final void Function(double value) onChangedWeight;
  final TextEditingController controller;

  const WeightedSetRow(
      {super.key,
      required this.controller,
      required this.onChangedReps,
      required this.onChangedWeight,
      required super.index,
      required super.label,
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
    int reps = 0;

    if (previousSetDto != null) {
      weight = isDefaultWeightUnit() ? previousSetDto.value1.toDouble() : toLbs(previousSetDto.value1.toDouble());
      reps = previousSetDto.value2.toInt();
    } else {
      weight = isDefaultWeightUnit() ? setDto.value1.toDouble() : toLbs(setDto.value1.toDouble());
      reps = setDto.value2.toInt();
    }

    return Table(
      columnWidths: editorType == RoutineEditorType.edit
          ? <int, TableColumnWidth>{
              0: const FixedColumnWidth(30),
              1: const FlexColumnWidth(3),
              2: const FlexColumnWidth(2),
              3: const FlexColumnWidth(2),
            }
          : <int, TableColumnWidth>{
              0: const FixedColumnWidth(30),
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
                label: label,
                onSelectSetType: onChangedType,
                onRemoveSet: onRemoved,
                type: setDto.type,
              )),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: previousSetDto != null
                ? Text(
                    "${previousSetDto.value2.toDouble()}${weightLabel()} x ${previousSetDto.value2.toInt()}",
                    style: GoogleFonts.lato(
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  )
                : Text("-", textAlign: TextAlign.center, style: GoogleFonts.lato(color: Colors.white70)),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: SetDoubleTextField(
              value: weight,
              onChanged: onChangedWeight, controller: controller,
            ),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: SetIntTextField(
              value: reps,
              onChanged: onChangedReps,
              controller: controller,
            ),
          ),
          if (editorType == RoutineEditorType.log)
            TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: SetCheckButton(setDto: setDto, onCheck: onCheck))
        ])
      ],
    );
  }
}

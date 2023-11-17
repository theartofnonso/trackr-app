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

    double prevWeightValue = 0;

    if (previousSetDto != null) {
      prevWeightValue =
          isDefaultWeightUnit() ? previousSetDto.value1.toDouble() : toLbs(previousSetDto.value1.toDouble());
    }

    final defaultWeightUnit = isDefaultWeightUnit();
    final weightValue = defaultWeightUnit ? setDto.value1.toDouble() : toLbs(setDto.value1.toDouble());

    final repsValue = setDto.value2.toInt();

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
                    "$prevWeightValue${weightLabel()} x ${previousSetDto.value2}",
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
              value: weightValue,
              onChanged: onChangedWeight,
            ),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: SetIntTextField(
              value: repsValue,
              onChanged: onChangedReps,
              setId: setDto.id,
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/widgets/routine/editor/textfields/set_double_textfield.dart';
import 'package:tracker_app/widgets/routine/editor/textfields/set_int_textfield.dart';

import '../../../../dtos/set_dto.dart';
import '../../../../screens/editor/routine_editor_screen.dart';
import '../../../../utils/general_utils.dart';
import '../set_type_icon.dart';

class WeightedSetRow extends StatelessWidget {
  final int index;
  final int workingIndex;
  final SetDto setDto;
  final SetDto? pastSetDto;
  final RoutineEditorType editorType;
  final void Function() onTapCheck;
  final void Function() onRemoved;
  final void Function(SetType type) onChangedType;
  final void Function(int value) onChangedReps;
  final void Function(double value) onChangedWeight;

  const WeightedSetRow(
      {super.key,
      required this.index,
      required this.workingIndex,
      required this.setDto,
      this.pastSetDto,
      required this.editorType,
      required this.onTapCheck,
      required this.onRemoved,
      required this.onChangedType,
      required this.onChangedReps,
      required this.onChangedWeight});

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
                type: setDto.type,
                label: workingIndex,
                onSelectSetType: onChangedType,
                onRemoveSet: onRemoved,
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
              editingController: TextEditingController(),
            ),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: SetIntTextField(
              value: repsValue,
              onChanged: onChangedReps,
              editingController: TextEditingController(),
            ),
          ),
          if (editorType == RoutineEditorType.log)
            TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: GestureDetector(
                  onTap: onTapCheck,
                  child: setDto.checked
                      ? const Icon(Icons.check_box_rounded, color: Colors.green)
                      : const Icon(Icons.check_box_rounded, color: Colors.grey),
                ))
        ])
      ],
    );
  }
}

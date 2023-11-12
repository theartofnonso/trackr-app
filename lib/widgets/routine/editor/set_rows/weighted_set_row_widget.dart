import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/dtos/weighted_set_dto.dart';
import 'package:tracker_app/widgets/routine/editor/textfields/set_double_textfield.dart';
import 'package:tracker_app/widgets/routine/editor/textfields/set_int_textfield.dart';
import 'package:tracker_app/widgets/routine/editor/set_rows/set_row_widget.dart';

import '../../../../dtos/set_dto.dart';
import '../../../../screens/editor/routine_editor_screen.dart';
import '../../../../utils/general_utils.dart';
import '../set_type_icon.dart';

class WeightedSetRowWidget extends SetRowWidget {
  const WeightedSetRowWidget(
      {Key? key,
      required int index,
      required int workingIndex,
      required WeightedSetDto setDto,
      WeightedSetDto? pastSetDto,
      RoutineEditorType editorType = RoutineEditorType.edit,
      required VoidCallback onTapCheck,
      required VoidCallback onRemoved,
      required void Function(int value) onChangedReps,
      required void Function(double value) onChangedWeight,
      required void Function(SetType type) onChangedType})
      : super(
            key: key,
            index: index,
            workingIndex: workingIndex,
            setDto: setDto,
            pastSetDto: pastSetDto,
            editorType: editorType,
            onTapCheck: onTapCheck,
            onRemoved: onRemoved,
            onChangedType: onChangedType,
            onChangedReps: onChangedReps,
            onChangedWeight: onChangedWeight);

  @override
  Widget build(BuildContext context) {
    final previousSetDto = pastSetDto as WeightedSetDto?;

    double prevWeightValue = 0;

    if (previousSetDto != null) {
      prevWeightValue =
          isDefaultWeightUnit() ? previousSetDto.first.toDouble() : toLbs(previousSetDto.first.toDouble());
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
                type: setDto.type,
                label: workingIndex,
                onSelectSetType: onChangedType,
                onRemoveSet: onRemoved,
              )),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: previousSetDto != null
                ? Text(
                    "$prevWeightValue${weightLabel()} x ${previousSetDto.first}",
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
              initialValue: (setDto as WeightedSetDto).first.toDouble(),
              onChanged: (value) {
                final callback = onChangedWeight;
                if (callback != null) {
                  callback(value);
                }
              },
            ),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: SetIntTextField(
              initialValue: (setDto as WeightedSetDto).second.toInt(),
              onChanged: (value) {
                final callback = onChangedReps;
                if (callback != null) {
                  callback(value);
                }
              },
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

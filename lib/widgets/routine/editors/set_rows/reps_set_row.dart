import 'package:flutter/material.dart';
import '../../../../colors.dart';
import 'package:tracker_app/dtos/set_dtos/reps_dto.dart';
import 'package:tracker_app/widgets/routine/editors/textfields/int_textfield.dart';

import '../../../../enums/routine_editor_type_enums.dart';
import '../set_check_button.dart';
import '../set_delete_button.dart';

class RepsSetRow extends StatelessWidget {
  final RepsSetDto setDto;
  final VoidCallback onRemoved;
  final VoidCallback onCheck;
  final RoutineEditorMode editorType;
  final void Function() onTapRepsEditor;
  final TextEditingController controller;
  final void Function(int reps) onChangedReps;

  const RepsSetRow({
    super.key,
    required this.setDto,
    required this.onRemoved,
    required this.onCheck,
    required this.controller,
    required this.onChangedReps,
    required this.onTapRepsEditor,
    required this.editorType,
  });

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    int reps = (setDto).reps;

    return Table(
      border: TableBorder.all(
          color: isDarkMode ? darkBorder : Colors.black38,
          borderRadius: BorderRadius.circular(radiusSM)),
      columnWidths: <int, TableColumnWidth>{
        0: const FixedColumnWidth(50),
        1: const FlexColumnWidth(1),
        2: const FixedColumnWidth(60),
      },
      children: [
        TableRow(children: [
          TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Center(child: SetDeleteButton(onDelete: onRemoved))),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: IntTextField(
              value: reps,
              onChanged: onChangedReps,
              onTap: onTapRepsEditor,
              controller: controller,
              maxLength: 2,
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

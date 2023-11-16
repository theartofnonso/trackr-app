import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/providers/procedures_provider.dart';
import 'package:tracker_app/widgets/routine/editor/textfields/set_int_textfield.dart';

import '../../../../dtos/set_dto.dart';
import '../../../../screens/editor/routine_editor_screen.dart';
import '../set_check_button.dart';
import '../set_type_icon.dart';

class RepsSetRow extends StatelessWidget {
  final int index;
  final String label;
  final String exerciseId;
  final SetDto setDto;
  final SetDto? pastSetDto;
  final RoutineEditorType editorType;
  final void Function() onCheck;
  final void Function() onRemoved;
  final void Function(SetType type) onChangedType;
  final void Function(num value) onChangedReps;

  const RepsSetRow(
      {super.key,
      required this.index,
      required this.label,
      required this.setDto,
      this.pastSetDto,
      required this.editorType,
      required this.onCheck,
      required this.onRemoved,
      required this.onChangedType,
      required this.onChangedReps, required this.exerciseId});

  @override
  Widget build(BuildContext context) {
    final previousSetDto = pastSetDto;

    int prevRepValue = 0;

    if (previousSetDto != null) {
      prevRepValue = previousSetDto.value2.toInt();
    }

    return Table(
      columnWidths: editorType == RoutineEditorType.edit
          ? <int, TableColumnWidth>{
              0: const FixedColumnWidth(30),
              1: const FlexColumnWidth(3),
              2: const FlexColumnWidth(1),
            }
          : <int, TableColumnWidth>{
              0: const FixedColumnWidth(30),
              1: const FlexColumnWidth(3),
              2: const FlexColumnWidth(2),
              3: const FlexColumnWidth(1),
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
                    "x $prevRepValue",
                    style: GoogleFonts.lato(color: Colors.white70),
                    textAlign: TextAlign.center,
                  )
                : Text("-", textAlign: TextAlign.center, style: GoogleFonts.lato(color: Colors.white70)),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: SetIntTextField(
              value: setDto.value2.toInt(),
              onChanged: onChangedReps,
            ),
          ),
          if (editorType == RoutineEditorType.log)
            TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: SetCheckButton(exerciseId: exerciseId, setIndex: index, onCheckSet: onCheck))
        ])
      ],
    );
  }
}

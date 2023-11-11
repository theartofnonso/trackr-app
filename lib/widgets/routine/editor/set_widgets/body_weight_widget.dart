import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/dtos/weight_reps_dto.dart';
import 'package:tracker_app/widgets/routine/editor/textfields/set_int_textfield.dart';
import 'package:tracker_app/widgets/routine/editor/set_widgets/set_widget.dart';

import '../../../../dtos/set_dto.dart';
import '../../../../screens/editor/routine_editor_screen.dart';
import '../../../../utils/general_utils.dart';
import '../set_type_icon.dart';

class BodyWeightWidget extends SetWidget {
  const BodyWeightWidget(
      {Key? key,
      required int index,
      required int workingIndex,
      required SetDto setDto,
      SetDto? pastSetDto,
      RoutineEditorType editorType = RoutineEditorType.edit,
      required VoidCallback onTapCheck,
      required VoidCallback onRemoved,
      required void Function(int value) onChangedReps,
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
          onChangedReps: onChangedReps,
          onChangedType: onChangedType,
        );

  @override
  Widget build(BuildContext context) {
    final previousSetDto = pastSetDto as WeightRepsDto?;

    double prevWeightValue = 0;

    if (previousSetDto != null) {
      prevWeightValue = isDefaultWeightUnit() ? previousSetDto.weight : toLbs(previousSetDto.weight);
    }

    return Table(
      columnWidths: const <int, TableColumnWidth>{
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(3),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(1),
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
                    "$prevWeightValue${weightLabel()} x ${previousSetDto.reps}",
                    style: GoogleFonts.lato(
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  )
                : Text("-", textAlign: TextAlign.center, style: GoogleFonts.lato(color: Colors.white70)),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: SetIntTextField(
              initialValue: (setDto as WeightRepsDto).reps,
              onChanged: (value) {
                final callback = onChangedReps;
                if(callback != null) {
                  callback(value);
                }
              },
            ),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: editorType == RoutineEditorType.log
                ? GestureDetector(
                    onTap: onTapCheck,
                    child: setDto.checked
                        ? const Icon(Icons.check_box_rounded, color: Colors.green)
                        : const Icon(Icons.check_box_rounded, color: Colors.grey),
                  )
                : const SizedBox.shrink(),
          )
        ])
      ],
    );
  }
}



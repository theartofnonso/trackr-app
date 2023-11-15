import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/dtos/duration_num_pair.dart';
import 'package:tracker_app/utils/datetime_utils.dart';

import '../../../../dtos/set_dto.dart';
import '../../../../screens/editor/routine_editor_screen.dart';
import '../set_type_icon.dart';
import '../timer_widget.dart';

class DurationSetRow extends StatelessWidget {
  final int index;
  final int workingIndex;
  final DurationNumPair setDto;
  final DurationNumPair? pastSetDto;
  final RoutineEditorType editorType;
  final void Function() onTapCheck;
  final void Function() onRemoved;
  final void Function(SetType type) onChangedType;
  final void Function(Duration duration) onChangedDuration;

  const DurationSetRow(
      {super.key,
      required this.index,
      required this.workingIndex,
      required this.setDto,
      this.pastSetDto,
      required this.editorType,
      required this.onTapCheck,
      required this.onRemoved,
      required this.onChangedType,
      required this.onChangedDuration});

  @override
  Widget build(BuildContext context) {
    final previousSetDto = pastSetDto;

    return Table(
      columnWidths: editorType == RoutineEditorType.edit
          ? <int, TableColumnWidth>{
              0: const FixedColumnWidth(30),
              1: const FlexColumnWidth(2),
              2: const FlexColumnWidth(2),
            }
          : <int, TableColumnWidth>{
              0: const FixedColumnWidth(25),
              1: const FlexColumnWidth(2),
              2: const FlexColumnWidth(2),
              3: const FlexColumnWidth(1),
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
                    previousSetDto.value1.secondsOrMinutesOrHours(),
                    style: GoogleFonts.lato(
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  )
                : Text("-", textAlign: TextAlign.center, style: GoogleFonts.lato(color: Colors.white70)),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: TimerWidget(
              durationDto: setDto,
              onChangedDuration: (Duration duration) => onChangedDuration(duration),
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

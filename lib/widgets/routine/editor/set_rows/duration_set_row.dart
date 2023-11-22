import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/widgets/routine/editor/set_rows/set_row.dart';

import '../../../../app_constants.dart';
import '../../../../screens/editors/routine_editor_screen.dart';
import '../set_check_button.dart';
import '../set_type_icon.dart';
import '../timer_widget.dart';

class DurationSetRow extends SetRow {
  final void Function(Duration duration) onChangedDuration;

  const DurationSetRow(
      {super.key,
      required this.onChangedDuration,
      required super.index,
      required super.setTypeIndex,
      required super.procedureId,
      required super.setDto,
      required super.pastSetDto,
      required super.editorType,
      required super.onRemoved,
      required super.onChangedType,
      required super.onCheck,
      required super.onUpdateSetWithPastSet});

  @override
  Widget build(BuildContext context) {
    final previousSetDto = pastSetDto;

    Duration duration = Duration.zero;

    if(previousSetDto != null) {
      duration = Duration(milliseconds: previousSetDto.value1.toInt());
      onUpdateSetWithPastSet(previousSetDto.copyWith(checked: setDto.checked));
    } else {
      duration = Duration(milliseconds: setDto.value1.toInt());
    }

    return Table(
      border: TableBorder.all(color: tealBlueLighter, borderRadius: BorderRadius.circular(5)),
      columnWidths: editorType == RoutineEditorMode.edit
          ? <int, TableColumnWidth>{
              0: const FixedColumnWidth(50),
              1: const FlexColumnWidth(2),
              2: const FlexColumnWidth(2),
            }
          : <int, TableColumnWidth>{
              0: const FixedColumnWidth(50),
              1: const FlexColumnWidth(2),
              2: const FlexColumnWidth(2),
              3: const FlexColumnWidth(1),
            },
      children: [
        TableRow(children: [
          TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: SetTypeIcon(
                label: "${setDto.type.label}${setTypeIndex + 1}",
                onSelectSetType: onChangedType,
                onRemoveSet: onRemoved,
                type: setDto.type,
              )),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: previousSetDto != null
                ? Text(
                    Duration(milliseconds: previousSetDto.value1.toInt()).digitalTime(),
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
              duration: duration,
              onChangedDuration: (Duration duration) => onChangedDuration(duration),
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/extensions/duration_extension.dart';

import '../../../../app_constants.dart';
import '../../../../dtos/set_dto.dart';
import '../../../../enums/routine_editor_type_enums.dart';
import '../../../timers/routine_timer.dart';
import '../set_check_button.dart';
import '../set_delete_button.dart';

class DurationSetRow extends StatelessWidget {
  final SetDto setDto;
  final RoutineEditorMode editorType;
  final VoidCallback onRemoved;
  final VoidCallback onCheck;
  final DateTime startTime;
  final void Function(Duration duration) onChangedDuration;

  const DurationSetRow({
    super.key,
    required this.setDto,
    required this.editorType,
    required this.onRemoved,
    required this.onCheck,
    required this.onChangedDuration,
    required this.startTime,
  });

  void _stopTimer() {
    if (setDto.checked) return;
    onChangedDuration(DateTime.now().difference(startTime));
  }

  @override
  Widget build(BuildContext context) {
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
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Center(child: SetDeleteButton(onDelete: onRemoved))),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: SizedBox(
              height: 50,
              child: Center(
                child: setDto.checked
                    ? Text(Duration(milliseconds: setDto.value1.toInt()).hmsDigital(),
                        style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600))
                    : RoutineTimer(
                        startTime: startTime,
                        digital: true,
                      ),
              ),
            ),
          ),
          if (editorType == RoutineEditorMode.log)
            TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: SetCheckButton(setDto: setDto, onCheck: _stopTimer))
        ])
      ],
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/dtos/set_dtos/duration_set_dto.dart';
import 'package:tracker_app/extensions/duration_extension.dart';

import '../../../../enums/routine_editor_type_enums.dart';
import '../../../../utils/dialog_utils.dart';
import '../set_delete_button.dart';

class DurationSetRow extends StatelessWidget {
  final DurationSetDto setDto;
  final VoidCallback onRemoved;
  final VoidCallback onCheck;
  final RoutineEditorMode editorType;
  final DateTime startTime;
  final void Function(Duration duration, bool shouldCheck) onUpdateDuration;

  const DurationSetRow({
    super.key,
    required this.setDto,
    required this.onRemoved,
    required this.onCheck,
    required this.onUpdateDuration,
    required this.startTime,
    required this.editorType,
  });

  void _selectTime({required BuildContext context}) {
    displayTimePicker(
        context: context,
        initialDuration: setDto.duration,
        mode: CupertinoTimerPickerMode.hms,
        onChangedDuration: (Duration duration) {
          Navigator.of(context).pop();
          onUpdateDuration(duration, true);
        });
  }

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return (Table(
        border: TableBorder.all(
            color: isDarkMode ? darkBorder : Colors.black38,
            borderRadius: BorderRadius.circular(radiusSM)),
        columnWidths: <int, TableColumnWidth>{
          0: const FixedColumnWidth(50),
          1: const FlexColumnWidth(1),
        },
        children: [
          TableRow(children: [
            TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Center(child: SetDeleteButton(onDelete: onRemoved))),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: GestureDetector(
                onTap: () => _selectTime(context: context),
                child: SizedBox(
                  height: 50,
                  child: Center(
                    child: Text(setDto.duration.hmsDigital(),
                        style: GoogleFonts.ubuntu(fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ),
          ])
        ]));
  }
}

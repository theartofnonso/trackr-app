import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/extensions/duration_extension.dart';

import '../../../../app_constants.dart';
import '../../../../dtos/set_dto.dart';
import '../../../../enums/routine_editor_type_enums.dart';
import '../../../timers/routine_timer.dart';
import '../set_check_button.dart';
import '../set_delete_button.dart';

class DurationSetRow extends StatefulWidget {
  final SetDto setDto;
  final RoutineEditorMode editorType;
  final VoidCallback onRemoved;
  final VoidCallback onCheck;
  final void Function(Duration duration) onChangedDuration;

  const DurationSetRow({
    super.key,
    required this.setDto,
    required this.editorType,
    required this.onRemoved,
    required this.onCheck,
    required this.onChangedDuration,
  });

  @override
  State<DurationSetRow> createState() => _DurationSetRowState();
}

class _DurationSetRowState extends State<DurationSetRow> {
  late DateTime _startTime;

  bool _started = false;

  void _toggleTimer({required Duration duration}) {
    if (_started) {
      widget.onChangedDuration(DateTime.now().difference(_startTime));
    } else {
      _startTime = DateTime.now().subtract(duration);
    }

    setState(() {
      _started = !_started;
    });
  }

  @override
  Widget build(BuildContext context) {
    Duration duration = Duration(milliseconds: widget.setDto.value1.toInt());
    return Table(
      border: TableBorder.all(color: tealBlueLighter, borderRadius: BorderRadius.circular(5)),
      columnWidths: widget.editorType == RoutineEditorMode.edit
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
              child: Center(child: SetDeleteButton(onDelete: widget.onRemoved))),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Center(
              child: _started
                  ? GestureDetector(
                      onTap: () => _toggleTimer(duration: duration),
                      child: RoutineTimer(
                        startTime: _startTime,
                        digital: true,
                      ),
                    )
                  : Text(duration.hmsDigital(),
                      style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
          if (widget.editorType == RoutineEditorMode.log)
            TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: SetCheckButton(
                    setDto: widget.setDto,
                    onCheck: () {
                      _toggleTimer(duration: duration);
                      widget.onCheck();
                    }))
        ])
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
  }
}

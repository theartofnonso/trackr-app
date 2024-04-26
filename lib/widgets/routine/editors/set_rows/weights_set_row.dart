import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/enums/set_intensity_enum.dart';
import 'package:tracker_app/widgets/routine/editors/textfields/double_textfield.dart';
import 'package:tracker_app/widgets/routine/editors/textfields/int_textfield.dart';

import '../../../../dtos/set_dto.dart';
import '../../../../enums/routine_editor_type_enums.dart';
import '../set_check_button.dart';

class WeightsSetRow extends StatelessWidget {
  final SetDto setDto;
  final SetIntensity setIntensity;
  final RoutineEditorMode editorType;
  final VoidCallback onRemoved;
  final VoidCallback onCheck;
  final void Function(int value) onChangedReps;
  final void Function(double value) onChangedWeight;
  final (TextEditingController, TextEditingController) controllers;

  const WeightsSetRow({
    super.key,
    required this.setDto,
    required this.setIntensity,
    required this.editorType,
    required this.onRemoved,
    required this.onCheck,
    required this.onChangedReps,
    required this.onChangedWeight,
    required this.controllers,
  });

  @override
  Widget build(BuildContext context) {
    num weight = setDto.weightValue();
    int reps = setDto.repsValue().toInt();

    return Table(
      border: TableBorder.all(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
      columnWidths: editorType == RoutineEditorMode.edit
          ? <int, TableColumnWidth>{
              0: const FixedColumnWidth(50),
              1: const FlexColumnWidth(1),
              2: const FlexColumnWidth(1),
            }
          : <int, TableColumnWidth>{
              0: const FixedColumnWidth(50),
              1: const FlexColumnWidth(1),
              2: const FlexColumnWidth(1),
              3: const FixedColumnWidth(60)
            },
      children: [
        TableRow(children: [
          TableCell(verticalAlignment: TableCellVerticalAlignment.middle, child: Center(child: _setIntensityIcon())),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: DoubleTextField(
              value: weight,
              onChanged: (value) {
                onChangedWeight(value);
              },
              controller: controllers.$1,
            ),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: IntTextField(
              value: reps,
              onChanged: onChangedReps,
              controller: controllers.$2,
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

  Widget _setIntensityIcon() {
    return switch (setIntensity) {
      SetIntensity.easy => const FaIcon(FontAwesomeIcons.fire, color: vibrantBlue, size: 20),
      SetIntensity.hard => const FaIcon(FontAwesomeIcons.fire, color: Colors.red, size: 20),
      SetIntensity.warmup => const FaIcon(FontAwesomeIcons.heartPulse, color: vibrantBlue, size: 20),
      SetIntensity.cardio => const FaIcon(FontAwesomeIcons.fire, color: Colors.red, size: 20),
      SetIntensity.sufficient => const FaIcon(FontAwesomeIcons.fire, color: vibrantGreen, size: 20),
      SetIntensity.none => const FaIcon(FontAwesomeIcons.heart, color: Colors.grey, size: 20)
    };
  }
}

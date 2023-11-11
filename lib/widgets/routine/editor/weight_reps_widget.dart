import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/dtos/weight_reps_dto.dart';

import '../../../dtos/set_dto.dart';
import '../../../screens/editor/routine_editor_screen.dart';
import '../../../utils/general_utils.dart';
import '../editor/set_type_icon.dart';

class WeightRepsWidget extends StatelessWidget {
  const WeightRepsWidget({
    super.key,
    required this.index,
    required this.workingIndex,
    required this.setDto,
    required this.pastSetDto,
    this.editorType = RoutineEditorType.edit,
    required this.onTapCheck,
    required this.onRemoved,
    required this.onChangedReps,
    required this.onChangedWeight,
    required this.onChangedType,
  });

  final int index;
  final int workingIndex;
  final SetDto setDto;
  final SetDto? pastSetDto;
  final RoutineEditorType editorType;
  final void Function() onTapCheck;
  final void Function() onRemoved;
  final void Function(int value) onChangedReps;
  final void Function(double value) onChangedWeight;
  final void Function(SetType type) onChangedType;

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
        3: FlexColumnWidth(2),
        4: FlexColumnWidth(1),
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
            child: _WeightTextField(
              initialValue: (setDto as WeightRepsDto).weight,
              onChangedWeight: (value) => onChangedWeight(value),
            ),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: _RepsTextField(
              initialValue: (setDto as WeightRepsDto).reps,
              onChangedReps: (value) => onChangedReps(value),
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

class _RepsTextField extends StatelessWidget {
  final int initialValue;
  final void Function(int) onChangedReps;

  const _RepsTextField({
    required this.initialValue,
    required this.onChangedReps,
  });

  int _parseIntOrDefault({required String value}) {
    return int.tryParse(value) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (value) => onChangedReps(_parseIntOrDefault(value: value)),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: tealBlueLight)),
          fillColor: tealBlueLight,
          hintText: initialValue.toString(),
          hintStyle: GoogleFonts.lato(fontWeight: FontWeight.w600, color: Colors.grey)),
      keyboardType: TextInputType.number,
      maxLines: 1,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
    );
  }
}

class _WeightTextField extends StatelessWidget {
  final double initialValue;
  final void Function(double) onChangedWeight;

  const _WeightTextField({required this.initialValue, required this.onChangedWeight});

  double _parseDoubleOrDefault({required bool isDefaultWeightUnit, required String value}) {
    final doubleValue = double.tryParse(value) ?? 0;
    return isDefaultWeightUnit ? doubleValue : toKg(doubleValue) ;
  }

  @override
  Widget build(BuildContext context) {
    final defaultWeightUnit = isDefaultWeightUnit();
      final value = defaultWeightUnit ? initialValue : toLbs(initialValue);
      return TextField(
        onChanged: (value) => onChangedWeight(_parseDoubleOrDefault(isDefaultWeightUnit: defaultWeightUnit, value: value)),
        decoration: InputDecoration(
            contentPadding: EdgeInsets.zero,
            fillColor: tealBlueLight,
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: tealBlueLight)),
            hintText: value.toString(),
            hintStyle: GoogleFonts.lato(fontWeight: FontWeight.w600, color: Colors.grey)),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        maxLines: 1,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
      );
  }
}

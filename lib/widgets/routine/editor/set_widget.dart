import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/providers/settings_provider.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';

import '../../../screens/routine_editor_screen.dart';
import '../../../utils/general_utils.dart';
import '../../helper_widgets/dialog_helper.dart';

class SetWidget extends StatelessWidget {
  const SetWidget({
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
    final previousSetDto = pastSetDto;

    double prevWeightValue = 0;

    if (previousSetDto != null) {
      final weightProvider = Provider.of<SettingsProvider>(context, listen: false);
      prevWeightValue = weightProvider.isLbs ? toLbs(previousSetDto.weight) : previousSetDto.weight;
    }

    return Table(
      columnWidths: const <int, TableColumnWidth>{
        0: FlexColumnWidth(),
        1: FixedColumnWidth(110),
        2: FixedColumnWidth(85),
        3: FixedColumnWidth(55),
        4: FixedColumnWidth(55),
      },
      children: [
        TableRow(children: [
          TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: _SetIcon(
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
              initialValue: setDto.weight,
              onChangedWeight: (value) => onChangedWeight(value),
            ),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: _RepsTextField(
              initialValue: setDto.reps,
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

class _SetIcon extends StatelessWidget {
  final SetType type;
  final int label;
  final void Function(SetType type) onSelectSetType;
  final void Function() onRemoveSet;

  const _SetIcon({
    required this.type,
    required this.label,
    required this.onSelectSetType,
    required this.onRemoveSet,
  });

  void selectType(BuildContext context, SetType type) {
    Navigator.pop(context);
    onSelectSetType(type);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        displayBottomSheet(
            context: context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ListTile(
                    onTap: () => selectType(context, SetType.warmUp),
                    leading: Text("W",
                        style: GoogleFonts.lato(color: SetType.warmUp.color, fontWeight: FontWeight.bold, fontSize: 16)),
                    title: Text("Warm up Set", style: GoogleFonts.lato(fontSize: 14))),
                ListTile(
                    onTap: () => selectType(context, SetType.working),
                    leading: Text("1",
                        style: GoogleFonts.lato(color: SetType.working.color, fontWeight: FontWeight.bold, fontSize: 16)),
                    title: Text("Working Set", style: GoogleFonts.lato(fontSize: 14))),
                ListTile(
                    onTap: () => selectType(context, SetType.failure),
                    leading: Text("F",
                        style: GoogleFonts.lato(color: SetType.failure.color, fontWeight: FontWeight.bold, fontSize: 16)),
                    title: Text("Failure Set", style: GoogleFonts.lato(fontSize: 14))),
                ListTile(
                    onTap: () => selectType(context, SetType.drop),
                    leading: Text("D",
                        style: GoogleFonts.lato(color: SetType.drop.color, fontWeight: FontWeight.bold, fontSize: 16)),
                    title: Text("Drop Set", style: GoogleFonts.lato(fontSize: 14))),
                CTextButton(onPressed: () {
                  Navigator.pop(context);
                  onRemoveSet();
                }, label: "Remove Set", buttonColor: tealBlueDark,)
              ],
            ),
            height: 290);
      },
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        child: Text(
          type == SetType.working ? "${label + 1}" : type.label,
          style: GoogleFonts.lato(color: type.color, fontWeight: FontWeight.bold),
        ),
      ),
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

  double _parseDoubleOrDefault({required SettingsProvider provider, required String value}) {
    final doubleValue = double.tryParse(value) ?? 0;
    return provider.isLbs ? toKg(doubleValue) : doubleValue;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(builder: (_, provider, __) {
      final value = provider.isLbs ? toLbs(initialValue) : initialValue;
      return TextField(
        onChanged: (value) => onChangedWeight(_parseDoubleOrDefault(provider: provider, value: value)),
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
    });
  }
}

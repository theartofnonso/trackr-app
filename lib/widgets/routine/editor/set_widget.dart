import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/providers/weight_unit_provider.dart';

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
    this.editorType = RoutineEditorMode.editing,
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
  final RoutineEditorMode editorType;
  final void Function() onTapCheck;
  final void Function() onRemoved;
  final void Function(int value) onChangedReps;
  final void Function(double value) onChangedWeight;
  final void Function(SetType type) onChangedType;

  /// [MenuItemButton]
  List<Widget> _menuActionButtons(BuildContext context) {
    return [
      MenuItemButton(
        onPressed: () {
          _showProcedureTypePicker(context: context);
        },
        leadingIcon: const Icon(Icons.find_replace_rounded),
        child: const Text("Change type"),
      ),
      MenuItemButton(
        onPressed: () {
          onRemoved();
        },
        leadingIcon: const Icon(Icons.delete_sweep, color: Colors.red),
        child: const Text(
          "Remove",
          style: TextStyle(color: Colors.red),
        ),
      )
    ];
  }

  void _showProcedureTypePicker({required BuildContext context}) {
    showModalPopup(
        context: context,
        child: _SetTypesList(
          onSelect: (SetType type) => onChangedType(type),
          currentType: setDto.type,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final previousSetDto = pastSetDto;

    double prevWeightValue = 0;

    if (previousSetDto != null) {
      final weightProvider = Provider.of<WeightUnitProvider>(context, listen: false);
      prevWeightValue = weightProvider.isLbs ? toLbs(previousSetDto.weight) : previousSetDto.weight;
    }

    return Table(
      columnWidths: const <int, TableColumnWidth>{
        0: FlexColumnWidth(),
        1: FixedColumnWidth(120),
        2: FixedColumnWidth(85),
        3: FixedColumnWidth(55),
        4: FlexColumnWidth(),
      },
      children: [
        TableRow(children: [
          TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: _SetIcon(type: setDto.type, label: workingIndex)),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: previousSetDto != null
                ? Text(
                    "$prevWeightValue${weightLabel()} x ${previousSetDto.reps}",
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  )
                : const Text("-", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
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
            child: editorType == RoutineEditorMode.routine
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
  const _SetIcon({
    required this.type,
    required this.label,
  });

  final SetType type;
  final int label;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.transparent,
      child: Text(
        type == SetType.working ? "${label + 1}" : type.label,
        style: TextStyle(color: type.color, fontWeight: FontWeight.bold),
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
    return SizedBox(
      width: 0,
      child: TextField(
        onChanged: (value) => onChangedReps(_parseIntOrDefault(value: value)),
        decoration: InputDecoration(
            contentPadding: EdgeInsets.zero,
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: tealBlueLight)),
            hintText: initialValue.toString(),
            hintStyle: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
        keyboardType: TextInputType.number,
        maxLines: 1,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
      ),
    );
  }
}

class _WeightTextField extends StatelessWidget {
  final double initialValue;
  final void Function(double) onChangedWeight;

  const _WeightTextField({required this.initialValue, required this.onChangedWeight});

  double _parseDoubleOrDefault({required WeightUnitProvider provider, required String value}) {
    final doubleValue = double.tryParse(value) ?? 0;
    return provider.isLbs ? toKg(doubleValue) : doubleValue;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 0,
      child: Consumer<WeightUnitProvider>(builder: (_, provider, __) {
        final value = provider.isLbs ? toLbs(initialValue) : initialValue;
        return TextField(
          onChanged: (value) => onChangedWeight(_parseDoubleOrDefault(provider: provider, value: value)),
          decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: tealBlueLight)),
              hintText: value.toString(),
              hintStyle: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
          keyboardType: TextInputType.number,
          maxLines: 1,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
        );
      }),
    );
  }
}

class _SetTypesList extends StatefulWidget {
  final SetType currentType;
  final void Function(SetType type) onSelect;

  const _SetTypesList({required this.onSelect, required this.currentType});

  @override
  State<_SetTypesList> createState() => _SetTypesListState();
}

class _SetTypesListState extends State<_SetTypesList> {
  late SetType _setType;
  late List<SetType> _procedureTypes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
            widget.onSelect(_setType);
          },
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Text(
              "Select",
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ),
        Flexible(
          child: CupertinoPicker(
            magnification: 1.22,
            squeeze: 1.2,
            useMagnifier: true,
            itemExtent: 32.0,
            // This is called when selected item is changed.
            onSelectedItemChanged: (int index) {
              setState(() {
                _setType = _procedureTypes[index];
              });
            },
            children: List<Widget>.generate(_procedureTypes.length, (int index) {
              return Center(
                  child: Text(
                _procedureTypes[index].name,
                style: const TextStyle(color: Colors.white),
              ));
            }),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _procedureTypes = SetType.values.whereNot((type) => type == widget.currentType).toList();
    _setType = _procedureTypes.first;
  }
}

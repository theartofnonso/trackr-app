import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/dtos/set_dto.dart';

import '../../../screens/routine_editor_screen.dart';
import '../../helper_widgets/dialog_helper.dart';

class SetWidget extends StatelessWidget {
  const SetWidget({
    super.key,
    required this.index,
    required this.workingIndex,
    required this.setDto,
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
    return ListTile(
      contentPadding: EdgeInsets.zero,
      horizontalTitleGap: 20,
      leading: SizedBox(width: 30, child: _SetIcon(type: setDto.type, label: workingIndex)),
      title: Row(
        children: [
          _RepsTextField(
            initialValue: setDto.reps,
            onChangedReps: (value) => onChangedReps(value),
          ),
          const SizedBox(
            width: 20,
          ),
          _WeightTextField(
            initialValue: setDto.weight,
            onChangedWeight: (value) => onChangedWeight(value),
          ),
          editorType == RoutineEditorMode.routine
              ? GestureDetector(
                  onTap: onTapCheck,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 45.0),
                    child: setDto.checked
                        ? const Icon(Icons.check_box_rounded, color: Colors.green)
                        : const Icon(Icons.check_box_rounded, color: Colors.grey),
                  ),
                )
              : const SizedBox.shrink()
        ],
      ),
      trailing: MenuAnchor(
          style: MenuStyle(
            backgroundColor: MaterialStateProperty.all(tealBlueLighter),
          ),
          builder: (BuildContext context, MenuController controller, Widget? child) {
            return IconButton(
              onPressed: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              icon: const Icon(Icons.more_horiz_rounded, color: Colors.white),
              tooltip: 'Show menu',
            );
          },
          menuChildren: _menuActionButtons(context)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3.0), // Adjust the border radius as needed
      ),
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

  const _RepsTextField({required this.initialValue, required this.onChangedReps,});

  int _parseIntOrDefault({required String value}) {
    return int.tryParse(value) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
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

  double _parseDoubleOrDefault({required String value}) {
    return double.tryParse(value) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      child: TextField(
        onChanged: (value) => onChangedWeight(_parseDoubleOrDefault(value: value)),
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

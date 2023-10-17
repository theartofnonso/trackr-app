import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/dtos/set_dto.dart';

import '../../../screens/workout_editor_screen.dart';
import '../../helper_widgets/dialog_helper.dart';

class SetWidget extends StatelessWidget {
  const SetWidget({
    super.key,
    required this.index,
    required this.workingIndex,
    required this.setDto,
    this.editorType = WorkoutEditorType.editing,
    required this.onTapCheck,
    required this.onRemoved,
    required this.onChangedRep,
    required this.onChangedWeight,
    required this.onChangedType,
  });

  final int index;
  final int workingIndex;
  final SetDto setDto;
  final WorkoutEditorType editorType;
  final void Function() onTapCheck;
  final void Function() onRemoved;
  final void Function(int value) onChangedRep;
  final void Function(int value) onChangedWeight;
  final void Function(SetType type) onChangedType;

  /// Show [CupertinoActionSheet]
  void _showSetActionSheet({required BuildContext context}) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(color: tealBlueDark);
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showProcedureTypePicker(context: context);
            },
            child: Text('Change Set type', style: textStyle),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              onRemoved();
            },
            child: const Text('Remove set', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
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
    return CupertinoListTile.notched(
      backgroundColor: tealBlueLight,
      leading: _SetIcon(type: setDto.type, label: workingIndex),
      title: Row(
        children: [
          _SetTextField(label: 'Reps', initialValue: setDto.rep, onChanged: (value) => onChangedRep(value)),
          const SizedBox(
            width: 15,
          ),
          _SetTextField(label: 'kg', initialValue: setDto.weight, onChanged: (value) => onChangedWeight(value)),
          editorType == WorkoutEditorType.routine
              ? GestureDetector(
                  onTap: onTapCheck,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: setDto.checked
                        ? const Icon(CupertinoIcons.check_mark_circled_solid, color: CupertinoColors.activeGreen)
                        : const Icon(CupertinoIcons.check_mark_circled, color: CupertinoColors.inactiveGray),
                  ),
                )
              : const SizedBox.shrink()
        ],
      ),
      trailing: GestureDetector(
          onTap: () => _showSetActionSheet(context: context),
          child: const Icon(
            CupertinoIcons.ellipsis,
            color: CupertinoColors.white,
          )),
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
      backgroundColor: type.color,
      child: Text(
        type == SetType.working ? "${label + 1}" : type.label,
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }
}

class _SetTextField extends StatelessWidget {
  final String label;
  final int initialValue;
  final void Function(int) onChanged;

  const _SetTextField({required this.label, required this.onChanged, required this.initialValue});

  int _parseIntOrDefault({required String value}) {
    return int.tryParse(value) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 85,
      child: CupertinoTextField(
        prefix: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(label,
              style: const TextStyle(color: CupertinoColors.systemGrey4, fontWeight: FontWeight.w600, fontSize: 12)),
        ),
        controller: TextEditingController(text: initialValue.toString()),
        onChanged: (value) => onChanged(_parseIntOrDefault(value: value)),
        decoration: const BoxDecoration(color: tealBlueLighter, borderRadius: BorderRadius.all(Radius.circular(8))),
        keyboardType: TextInputType.number,
        maxLines: 1,
        style: Theme.of(context).textTheme.bodyMedium,
        placeholderStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.transparent),
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
  late SetType _procedureType;
  late List<SetType> _procedureTypes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () => widget.onSelect(_procedureType),
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
                _procedureType = _procedureTypes[index];
              });
            },
            children: List<Widget>.generate(_procedureTypes.length, (int index) {
              return Center(
                  child: Text(
                _procedureTypes[index].name,
                style: const TextStyle(color: CupertinoColors.white),
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
    _procedureType = _procedureTypes.first;
  }
}

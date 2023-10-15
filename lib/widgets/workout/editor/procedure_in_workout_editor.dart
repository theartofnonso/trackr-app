import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/dtos/exercise_in_workout_dto.dart';
import 'package:tracker_app/dtos/procedure_dto.dart';

import '../../../screens/workout_editor_screen.dart';
import '../../helper_widgets/dialog_helper.dart';

class ProcedureInWorkoutEditor extends StatelessWidget {
  const ProcedureInWorkoutEditor({
    super.key,
    required this.index,
    required this.workingIndex,
    required this.exerciseInWorkoutDto,
    required this.procedureDto,
    this.editorType = WorkoutEditorType.editing,
    required this.onTapCheck,
    required this.onRemoved,
    required this.onChangedRepCount,
    required this.onChangedWeight,
    required this.onChangedType,
  });

  final int index;
  final int workingIndex;
  final ProcedureDto procedureDto;
  final WorkoutEditorType editorType;
  final void Function() onTapCheck;
  final void Function() onRemoved;
  final void Function(int value) onChangedRepCount;
  final void Function(int value) onChangedWeight;
  final void Function(ProcedureType type) onChangedType;

  final ExerciseInWorkoutDto exerciseInWorkoutDto;

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
        context: context, child: _ListOfProcedureTypes(onSelect: (ProcedureType type) => onChangedType(type), currentType: procedureDto.type,));
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile.notched(
      backgroundColor: tealBlueLight,
      leading: LeadingIcon(type: procedureDto.type, label: workingIndex),
      title: Row(
        children: [
          _ProcedureTextField(
              label: 'Reps', initialValue: procedureDto.repCount, onChanged: (value) => onChangedRepCount(value)),
          const SizedBox(
            width: 15,
          ),
          _ProcedureTextField(
              label: 'kg', initialValue: procedureDto.weight, onChanged: (value) => onChangedWeight(value)),
          editorType == WorkoutEditorType.routine ? GestureDetector(
            onTap: onTapCheck,
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: procedureDto.checked ? const Icon(CupertinoIcons.check_mark_circled_solid, color: CupertinoColors.activeGreen) : const Icon(CupertinoIcons.check_mark_circled, color: CupertinoColors.inactiveGray),
            ),
          ) : const SizedBox.shrink()
        ],
      ),
      trailing: GestureDetector(
          onTap: () => _showSetActionSheet(context: context),
          child: const Padding(
            padding: EdgeInsets.only(right: 9.0),
            child: Icon(CupertinoIcons.ellipsis, color: CupertinoColors.white,),
          )),
    );
  }
}

class LeadingIcon extends StatelessWidget {
  const LeadingIcon({
    super.key,
    required this.type,
    required this.label,
  });

  final ProcedureType type;
  final int label;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: type.color,
      child: Text(
        _generateLabel(),
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }

  String _generateLabel() {
    return type == ProcedureType.working ? "${label + 1}" : type.label;
  }
}

class _ProcedureTextField extends StatelessWidget {
  final String label;
  final int initialValue;
  final void Function(int) onChanged;

  const _ProcedureTextField({required this.label, required this.onChanged, required this.initialValue});

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

class _ListOfProcedureTypes extends StatefulWidget {
  final ProcedureType currentType;
  final void Function(ProcedureType type) onSelect;

  const _ListOfProcedureTypes({required this.onSelect, required this.currentType});

  @override
  State<_ListOfProcedureTypes> createState() => _ListOfProcedureTypesState();
}

class _ListOfProcedureTypesState extends State<_ListOfProcedureTypes> {
  late ProcedureType _procedureType;
  late List<ProcedureType> _procedureTypes;

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
    _procedureTypes = ProcedureType.values.whereNot((type) => type == widget.currentType).toList();
    _procedureType = _procedureTypes.first;
  }
}

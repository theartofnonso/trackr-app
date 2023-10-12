import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/dtos/exercise_in_workout_dto.dart';
import 'package:tracker_app/dtos/procedure_dto.dart';

import '../helper_widgets/dialog_helper.dart';

class SetListItem extends StatelessWidget {
  const SetListItem({
    super.key,
    required this.index,
    required this.workingIndex,
    required this.exerciseInWorkoutDto,
    required this.procedureDto,
    required this.onRemoved,
    required this.onChangedRepCount,
    required this.onChangedWeight,
    required this.onChangedType,
  });

  final int index;
  final int workingIndex;
  final ProcedureDto procedureDto;
  final void Function(int index) onRemoved;
  final void Function(int value) onChangedRepCount;
  final void Function(int value) onChangedWeight;
  final void Function(ProcedureType type) onChangedType;

  final ExerciseInWorkoutDto exerciseInWorkoutDto;

  /// Show [CupertinoActionSheet]
  void _showSetActionSheet({required BuildContext context}) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showProcedureTypePicker(context: context);
            },
            child: const Text('Change Set type', style: TextStyle(fontSize: 16)),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              onRemoved(index);
            },
            child: const Text('Remove set', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _showProcedureTypePicker({required BuildContext context}) {
    showModalPopup(
        context: context, child: _ListOfProcedureTypes(onSelect: (ProcedureType type) => onChangedType(type)));
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile.notched(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      backgroundColor: const Color.fromRGBO(25, 28, 36, 1),
      leading: LeadingIcon(type: procedureDto.type, label: workingIndex),
      title: Row(
        children: [
          _SetListItemTextField(
              label: 'Reps', initialValue: procedureDto.repCount, onChanged: (value) => onChangedRepCount(value)),
          const SizedBox(
            width: 15,
          ),
          _SetListItemTextField(
              label: 'kg', initialValue: procedureDto.weight, onChanged: (value) => onChangedWeight(value)),
        ],
      ),
      trailing: GestureDetector(
          onTap: () => _showSetActionSheet(context: context),
          child: const Padding(
            padding: EdgeInsets.only(right: 9.0),
            child: Icon(CupertinoIcons.ellipsis),
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
        style: const TextStyle(fontWeight: FontWeight.bold, color: CupertinoColors.white, fontSize: 12),
      ),
    );
  }

  String _generateLabel() {
    return type == ProcedureType.working ? "${label + 1}" : type.label;
  }
}

class _SetListItemTextField extends StatelessWidget {
  final String label;
  final int? initialValue;
  final void Function(int) onChanged;

  const _SetListItemTextField({required this.label, required this.onChanged, required this.initialValue});

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
        controller: TextEditingController(text: initialValue?.toString()),
        onChanged: (value) => onChanged(_parseIntOrDefault(value: value)),
        decoration: const BoxDecoration(color: tealBlueLighter, borderRadius: BorderRadius.all(Radius.circular(8))),
        keyboardType: TextInputType.number,
        maxLines: 1,
        placeholder: "0",
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        placeholderStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.transparent),
      ),
    );
  }
}

class _ListOfProcedureTypes extends StatefulWidget {
  final void Function(ProcedureType type) onSelect;

  const _ListOfProcedureTypes({required this.onSelect});

  @override
  State<_ListOfProcedureTypes> createState() => _ListOfProcedureTypesState();
}

class _ListOfProcedureTypesState extends State<_ListOfProcedureTypes> {
  late ProcedureType _procedureType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () => widget.onSelect(_procedureType),
          child: const Padding(
            padding: EdgeInsets.all(14.0),
            child: Text(
              "Select",
              style: TextStyle(fontWeight: FontWeight.bold),
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
                _procedureType = ProcedureType.values[index];
              });
            },
            children: List<Widget>.generate(ProcedureType.values.length, (int index) {
              return Center(
                  child: Text(
                ProcedureType.values[index].name,
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
    _procedureType = ProcedureType.values[0];
  }
}

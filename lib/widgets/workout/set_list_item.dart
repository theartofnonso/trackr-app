import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/dtos/exercise_in_workout_dto.dart';
import 'package:tracker_app/dtos/procedure_dto.dart';

class SetListItem extends StatelessWidget {
  const SetListItem({
    super.key,
    required this.index,
    required this.isWarmup,
    required this.exerciseInWorkoutDto,
    this.procedureDto,
    required this.onRemoved,
    required this.onChangedRepCount,
    required this.onChangedWeight,
  });

  final int index;
  final bool isWarmup;
  final ProcedureDto? procedureDto;
  final void Function(int index) onRemoved;
  final void Function(int value) onChangedRepCount;
  final void Function(int value) onChangedWeight;

  final ExerciseInWorkoutDto exerciseInWorkoutDto;

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile.notched(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      backgroundColor: const Color.fromRGBO(25, 28, 36, 1),
      leading: LeadingIcon(isWarmup: isWarmup, label: index),
      title: Row(
        children: [
          _SetListItemTextField(
              label: 'Reps',
              initialValue: procedureDto?.repCount,
              onChanged: (value) => onChangedRepCount(value)),
          const SizedBox(
            width: 15,
          ),
          _SetListItemTextField(
              label: 'kg',
              initialValue: procedureDto?.weight,
              onChanged: (value) => onChangedWeight(value)),
        ],
      ),
      subtitle: const Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Text("Previous: 10 Reps with 35kg", style: TextStyle(color: CupertinoColors.inactiveGray),),
      ),
      trailing: GestureDetector(onTap: () => onRemoved(index), child: Icon(CupertinoIcons.delete_solid, size: 18, color: CupertinoColors.systemRed.withOpacity(0.8),),),
    );
  }
}

class LeadingIcon extends StatelessWidget {
  const LeadingIcon({
    super.key,
    required this.isWarmup,
    required this.label,
  });

  final bool isWarmup;
  final int label;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor:
          isWarmup ? CupertinoColors.activeOrange : CupertinoColors.activeBlue,
      child: isWarmup
          ? Text(
              "W${label + 1}",
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.white,
                  fontSize: 12),
            )
          : Text(
              "${label + 1}",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: CupertinoColors.white),
            ),
    );
  }
}

class _SetListItemTextField extends StatelessWidget {
  final String label;
  final int? initialValue;
  final void Function(int) onChanged;

  const _SetListItemTextField(
      {required this.label,
      required this.onChanged,
      required this.initialValue});

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
              style: const TextStyle(
                  color: CupertinoColors.systemGrey4,
                  fontWeight: FontWeight.w600,
                  fontSize: 12)),
        ),
        controller: TextEditingController(text: initialValue?.toString()),
        onChanged: (value) => onChanged(_parseIntOrDefault(value: value)),
        decoration: const BoxDecoration(
            color: tealBlueLighter,
            borderRadius: BorderRadius.all(Radius.circular(8))),
        keyboardType: TextInputType.number,
        maxLines: 1,
        placeholder: "0",
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        placeholderStyle: const TextStyle(
            fontWeight: FontWeight.bold, color: Colors.transparent),
      ),
    );
  }
}

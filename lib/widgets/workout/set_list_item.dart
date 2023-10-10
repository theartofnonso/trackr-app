import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      background: Container(
        color: CupertinoColors.destructiveRed,
        padding: const EdgeInsets.only(right: 10),
        alignment: Alignment.centerRight,
        child: const Text("Delete",
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
      ),
      onDismissed: (_) => onRemoved(index),
      child: CupertinoListTile.notched(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        backgroundColor: const Color.fromRGBO(25, 28, 36, 1),
        leading: LeadingIcon(isWarmup: isWarmup, label: index),
        title: Row(
          children: [
            const SizedBox(
              width: 12,
            ),
            _SetListItemTextField(
                label: 'Reps',
                initialValue: procedureDto?.repCount,
                onChanged: (value) => onChangedRepCount(value)),
            const SizedBox(
              width: 25,
            ),
            _SetListItemTextField(
                label: 'kg',
                initialValue: procedureDto?.weight,
                onChanged: (value) => onChangedWeight(value)),
          ],
        ),
      ),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: CupertinoTextField(
            prefix: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(label, style: const TextStyle(color: CupertinoColors.opaqueSeparator, fontWeight: FontWeight.w600, fontSize: 12)),
            ),
            controller: TextEditingController(text: initialValue?.toString()),
            onChanged: (value) => onChanged(_parseIntOrDefault(value: value)),
            decoration: const BoxDecoration(color: tealBlueLighter, borderRadius: BorderRadius.all(Radius.circular(8))),
            keyboardType: TextInputType.number,
            maxLines: 1,
            placeholder: "0",
            style: const TextStyle(fontWeight: FontWeight.bold),
            placeholderStyle: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.transparent),
          ),
        )
      ],
    );
  }
}

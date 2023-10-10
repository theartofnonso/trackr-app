import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tracker_app/dtos/exercise_in_workout_dto.dart';
import 'package:tracker_app/dtos/procedure_dto.dart';

class SetListItem extends StatelessWidget {
  const SetListItem({
    required this.keyValue,
    required this.index,
    required this.isWarmup,
    required this.exerciseInWorkoutDto,
    this.procedureDto,
    required this.onRemoved,
    required this.onChangedRepCount,
    required this.onChangedWeight,
  }) : super(key: keyValue);

  final Key keyValue;
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
      key: keyValue,
      direction: DismissDirection.endToStart,
      background: Container(
        color: CupertinoColors.destructiveRed,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text("Delete",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            SizedBox(
              width: 10,
            ),
          ],
        ),
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

class _SetListItemTextField extends StatefulWidget {
  final String label;
  final int? initialValue;
  final void Function(int) onChanged;

  const _SetListItemTextField(
      {required this.label,
      required this.onChanged,
      required this.initialValue});

  @override
  State<_SetListItemTextField> createState() => _SetListItemTextFieldState();
}

class _SetListItemTextFieldState extends State<_SetListItemTextField> {
  int _parseOrDefault({required String value}) {
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
            prefix: Text(
              widget.label,
              style: const TextStyle(color: CupertinoColors.opaqueSeparator),
            ),
            controller:
                TextEditingController(text: widget.initialValue?.toString()),
            onChanged: (value) =>
                widget.onChanged(_parseOrDefault(value: value)),
            decoration: const BoxDecoration(color: Colors.transparent),
            keyboardType: TextInputType.number,
            maxLines: 1,
            style: const TextStyle(fontWeight: FontWeight.bold),
            placeholderStyle: const TextStyle(
                fontWeight: FontWeight.bold, color: CupertinoColors.white),
          ),
        )
      ],
    );
  }
}

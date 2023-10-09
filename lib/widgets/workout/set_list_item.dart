import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/exercise_in_workout_dto.dart';
import 'package:tracker_app/dtos/procedure_dto.dart';

import '../../providers/exercise_in_workout_provider.dart';

class SetListItem extends StatelessWidget {
  const SetListItem({
    super.key,
    required this.index,
    required this.onRemove,
    required this.isWarmup,
    this.previousWorkoutSummary, required this.exerciseInWorkoutDto, this.procedureDto,
  });

  final int index;
  final String? previousWorkoutSummary;
  final bool isWarmup;
  final void Function(int index) onRemove;
  final ProcedureDto? procedureDto;

  final ExerciseInWorkoutDto exerciseInWorkoutDto;

  /// Show [CupertinoActionSheet]
  void _showSetActionSheet({required BuildContext context}) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              onRemove(index);
            },
            child: const Text('Remove set'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile.notched(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      backgroundColor: const Color.fromRGBO(25, 28, 36, 1),
      leading: LeadingIcon(isWarmup: isWarmup, index: index),
      title: Row(
        children: [
          const SizedBox(
            width: 18,
          ),
          _SetListItemTextField(
              label: 'Reps',
              value: procedureDto?.repCount,
              onChanged: (value) =>
                  Provider.of<ExerciseInWorkoutProvider>(context, listen: false)
                      .updateReps(
                          exerciseInWorkout: exerciseInWorkoutDto,
                          setIndex: index,
                          repCount: int.parse(value),
                          isWarmup: isWarmup)),
          const SizedBox(
            width: 28,
          ),
          _SetListItemTextField(
              label: 'kg',
              value: procedureDto?.weight,
              onChanged: (value) =>
                  Provider.of<ExerciseInWorkoutProvider>(context, listen: false)
                      .updateWeight(
                          exerciseInWorkout: exerciseInWorkoutDto,
                          setIndex: index,
                          weight: int.parse(value),
                          isWarmup: isWarmup)),
          const SizedBox(
            width: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Past"),
              const SizedBox(
                height: 8,
              ),
              Text(previousWorkoutSummary ?? "No data",
                  style:
                      TextStyle(color: CupertinoColors.white.withOpacity(0.7)))
            ],
          )
        ],
      ),
      trailing: GestureDetector(
          onTap: () => _showSetActionSheet(context: context),
          child: const Icon(CupertinoIcons.ellipsis)),
    );
  }
}

class LeadingIcon extends StatelessWidget {
  const LeadingIcon({
    super.key,
    required this.isWarmup,
    required this.index,
  });

  final bool isWarmup;
  final int index;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor:
          isWarmup ? CupertinoColors.activeOrange : CupertinoColors.activeBlue,
      child: isWarmup
          ? Text(
              "W${index + 1}",
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.white,
                  fontSize: 12),
            )
          : Text(
              "${index + 1}",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: CupertinoColors.white),
            ),
    );
  }
}

class _SetListItemTextField extends StatelessWidget {
  final String label;
  final int? value;
  final void Function(String)? onChanged;

  const _SetListItemTextField({required this.label, this.onChanged, this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: CupertinoColors.opaqueSeparator),
        ),
        const SizedBox(
          height: 8,
        ),
        SizedBox(
          width: 30,
          child: CupertinoTextField(
            controller: value != null ? TextEditingController(text: value.toString()) : null,
            onChanged: onChanged,
            decoration: const BoxDecoration(color: Colors.transparent),
            padding: EdgeInsets.zero,
            keyboardType: TextInputType.number,
            maxLength: 3,
            maxLines: 1,
            placeholder: "0",
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            style: const TextStyle(fontWeight: FontWeight.bold),
            placeholderStyle: const TextStyle(
                fontWeight: FontWeight.bold, color: CupertinoColors.white),
            //onChanged: (value) => ,
          ),
        )
      ],
    );
  }
}

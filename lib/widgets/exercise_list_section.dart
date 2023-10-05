import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';

import 'exercise_list_item.dart';

class ExerciseListSection extends StatefulWidget {
  final BodyPart bodyPart;
  final List<Exercise> exercises;
  final void Function(Exercise exerciseToBeAdded) onSelect;
  final void Function(Exercise exerciseToBeRemoved) onRemove;

  const ExerciseListSection(
      {super.key,
      required this.exercises,
      required this.bodyPart,
      required this.onSelect,
      required this.onRemove});

  @override
  State<ExerciseListSection> createState() => _ExerciseListSectionState();
}

class _ExerciseListSectionState extends State<ExerciseListSection> {
  final listSectionStyle =
      TextStyle(color: CupertinoColors.white.withOpacity(0.7));

  List<ExerciseListItem> _exercisesToListItem(
      {required List<Exercise> exercises, required BodyPart bodyPart}) {
    return exercises
        .map((exercise) => ExerciseListItem(
              exercise: exercise,
              onTap: (value) => _onSelectExercise(
                  isSelected: value, selectedExercise: exercise),
            ))
        .toList();
  }

  void _onSelectExercise(
      {required bool isSelected, required Exercise selectedExercise}) {
    if (isSelected) {
      widget.onSelect(selectedExercise);
    } else {
      widget.onRemove(selectedExercise);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.exercises.isNotEmpty
        ? CupertinoListSection.insetGrouped(
            backgroundColor: Colors.transparent,
            header: Text(widget.bodyPart.label, style: listSectionStyle),
            children: [
              ..._exercisesToListItem(
                  exercises: widget.exercises, bodyPart: widget.bodyPart)
            ],
          )
        : const SizedBox.shrink();
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';

import 'exercise_item.dart';
import 'exercise_list_item.dart';

class ExerciseListSection extends StatefulWidget {
  final BodyPart bodyPart;
  final List<ExerciseItem> exercises;
  final void Function(ExerciseItem exerciseItemToBeAdded) onSelect;
  final void Function(ExerciseItem exerciseItemToBeRemoved) onRemove;

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
      {required List<ExerciseItem> exercises, required BodyPart bodyPart}) {
    return exercises
        .map((exerciseItem) => ExerciseListItem(
              exerciseItem: exerciseItem,
              onTap: (value) => _onSelectExercise(
                  isSelected: value, selectedExerciseItem: exerciseItem),
            ))
        .toList();
  }

  void _onSelectExercise(
      {required bool isSelected, required ExerciseItem selectedExerciseItem}) {
    if (isSelected) {
      selectedExerciseItem.isSelected = true;
      widget.onSelect(selectedExerciseItem);
    } else {
      selectedExerciseItem.isSelected = false;
      widget.onRemove(selectedExerciseItem);
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

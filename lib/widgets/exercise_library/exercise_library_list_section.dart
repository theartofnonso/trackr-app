import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';

import 'exercise_library_item.dart';
import 'exercise_library_list_item.dart';

class ExerciseLibraryListSection extends StatefulWidget {
  final BodyPart bodyPart;
  final List<ExerciseLibraryItem> exercises;
  final void Function(ExerciseLibraryItem exerciseItemToBeAdded) onSelect;
  final void Function(ExerciseLibraryItem exerciseItemToBeRemoved) onRemove;

  const ExerciseLibraryListSection(
      {super.key,
      required this.exercises,
      required this.bodyPart,
      required this.onSelect,
      required this.onRemove});

  @override
  State<ExerciseLibraryListSection> createState() => _ExerciseLibraryListSectionState();
}

class _ExerciseLibraryListSectionState extends State<ExerciseLibraryListSection> {
  final listSectionStyle =
      TextStyle(color: CupertinoColors.white.withOpacity(0.7));

  List<ExerciseLibraryListItem> _exercisesToListItem(
      {required List<ExerciseLibraryItem> exercises, required BodyPart bodyPart}) {
    return exercises
        .map((exerciseItem) => ExerciseLibraryListItem(
              exerciseItem: exerciseItem,
              onTap: (value) => _onSelectExercise(
                  isSelected: value, selectedExerciseItem: exerciseItem),
            ))
        .toList();
  }

  void _onSelectExercise(
      {required bool isSelected, required ExerciseLibraryItem selectedExerciseItem}) {
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
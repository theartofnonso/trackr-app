import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';

import '../../dtos/exercise_in_library_dto.dart';
import 'exercise_library_list_item.dart';

class ExerciseLibraryListSection extends StatefulWidget {
  final BodyPart bodyPart;
  final List<ExerciseInLibraryDto> exercises;
  final void Function(ExerciseInLibraryDto exerciseInLibrary) onSelect;
  final void Function(ExerciseInLibraryDto exerciseInLibrary) onRemove;

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

  /// Convert [ExerciseInLibraryDto] to [ExerciseLibraryListItem]
  List<ExerciseLibraryListItem> _exercisesToListItem(
      {required List<ExerciseInLibraryDto> exercises, required BodyPart bodyPart}) {
    return exercises
        .map((exercise) => ExerciseLibraryListItem(
              exercise: exercise,
              onTap: (isSelected) => _onSelectExercise(
                  isSelected: isSelected, selectedExercise: exercise),
            ))
        .toList();
  }

  /// Select an exercise
  void _onSelectExercise(
      {required bool isSelected, required ExerciseInLibraryDto selectedExercise}) {
    if (isSelected) {
      selectedExercise.isSelected = true;
      widget.onSelect(selectedExercise);
    } else {
      selectedExercise.isSelected = false;
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

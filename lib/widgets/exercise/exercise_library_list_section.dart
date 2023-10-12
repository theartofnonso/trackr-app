import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';
import 'package:tracker_app/widgets/exercise/exercise_library_list_item.dart';

import '../../dtos/exercise_in_library_dto.dart';
import 'selectable_exercise_library_list_item.dart';

class ExerciseLibraryListSection extends StatelessWidget {
  final BodyPart bodyPart;
  final bool multiSelect;
  final List<ExerciseInLibraryDto> exercises;
  final void Function(ExerciseInLibraryDto exerciseInLibrary) onSelect;
  final void Function(ExerciseInLibraryDto exerciseInLibrary) onRemove;

  const ExerciseLibraryListSection(
      {super.key,
      required this.exercises,
      required this.bodyPart,
      required this.onSelect,
      required this.onRemove,
      required this.multiSelect});

  /// Convert [ExerciseInLibraryDto] to [SelectableExrLibraryListItem]
  List<Widget> _exercisesToListItem(
      {required List<ExerciseInLibraryDto> exercises,
      required BodyPart bodyPart}) {
    return exercises
        .map((exercise) => multiSelect
            ? SelectableExrLibraryListItem(
                exercise: exercise,
                onTap: (isSelected) => _onSelectCheckedExercise(
                    isSelected: isSelected, selectedExercise: exercise),
              )
            : ExrLibraryListItem(
                exercise: exercise,
                onTap: () => _onSelectExercise(selectedExercise: exercise)))
        .toList();
  }

  /// Select up to many exercise
  void _onSelectCheckedExercise(
      {required bool isSelected,
      required ExerciseInLibraryDto selectedExercise}) {
    if (isSelected) {
      selectedExercise.isSelected = true;
      onSelect(selectedExercise);
    } else {
      selectedExercise.isSelected = false;
      onRemove(selectedExercise);
    }
  }

  /// Select an exercise
  void _onSelectExercise({required ExerciseInLibraryDto selectedExercise}) {
    onSelect(selectedExercise);
  }

  @override
  Widget build(BuildContext context) {
    return exercises.isNotEmpty
        ? CupertinoListSection.insetGrouped(
            backgroundColor: Colors.transparent,
            header: Text(bodyPart.label,
                style:
                    TextStyle(color: CupertinoColors.white.withOpacity(0.7))),
            children: [
              ..._exercisesToListItem(exercises: exercises, bodyPart: bodyPart)
            ],
          )
        : const SizedBox.shrink();
  }
}

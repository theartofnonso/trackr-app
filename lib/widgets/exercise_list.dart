import 'package:flutter/cupertino.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';

import 'exercise_list_item.dart';

class ExerciseList extends StatefulWidget {
  final BodyPart bodyPart;
  final List<Exercise> exercises;

  const ExerciseList({super.key, required this.exercises, required this.bodyPart});

  @override
  State<ExerciseList> createState() => _ExerciseListState();
}

class _ExerciseListState extends State<ExerciseList> {
  final List<Exercise> _selectedExercises = [];

  final listSectionStyle =
      TextStyle(color: CupertinoColors.white.withOpacity(0.7));

  List<ExerciseListItem> _exercisesToCupertinoListSection(
      {required List<Exercise> exercises, required BodyPart bodyPart}) {
    return exercises
        .map((exercise) => ExerciseListItem(
              exercise: exercise,
              onSelect: (value) => _onSelectExercise(
                  isSelected: value, selectedExercise: exercise),
            ))
        .toList();
  }

  void _onSelectExercise(
      {required bool isSelected, required Exercise selectedExercise}) {
    if (isSelected) {
      setState(() {
        _selectedExercises.add(selectedExercise);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.exercises.isNotEmpty ? CupertinoListSection.insetGrouped(
      header: Text(widget.bodyPart.label, style: listSectionStyle),
      children: [
        ..._exercisesToCupertinoListSection(
            exercises: widget.exercises, bodyPart: widget.bodyPart)
      ],
    ) : const SizedBox.shrink();
  }
}

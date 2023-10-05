import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';

import 'exercise_list_item.dart';
import 'exercise_list_section.dart';

class ExerciseList extends StatefulWidget {
  final List<Exercise> chestExercises;
  final List<Exercise> shouldersExercises;
  final List<Exercise> tricepsExercises;
  final List<Exercise> legsExercises;

  const ExerciseList(
      {super.key,
      required this.chestExercises,
      required this.shouldersExercises,
      required this.tricepsExercises,
      required this.legsExercises});

  @override
  State<ExerciseList> createState() => _ExerciseListSectionState();
}

class _ExerciseListSectionState extends State<ExerciseList> {
  final List<Exercise> _selectedExercises = [];

  final listSectionStyle =
      TextStyle(color: CupertinoColors.white.withOpacity(0.7));

  // List<ExerciseListItem> _exercisesToCupertinoListSection(
  //     {required List<Exercise> exercises, required BodyPart bodyPart}) {
  //   return exercises
  //       .map((exercise) => ExerciseListItem(
  //             exercise: exercise,
  //             onSelect: (value) => _onSelectExercise(
  //                 isSelected: value, selectedExercise: exercise),
  //           ))
  //       .toList();
  // }

  //
  // void _onSelectExercise(
  //     {required bool isSelected, required Exercise selectedExercise}) {
  //   if (isSelected) {
  //     setState(() {
  //       _selectedExercises.add(selectedExercise);
  //     });
  //   } else {
  //     setState(() {
  //       _selectedExercises.remove(selectedExercise);
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ExerciseListSection(
            exercises: widget.chestExercises, bodyPart: BodyPart.chest),
        ExerciseListSection(
            exercises: widget.shouldersExercises, bodyPart: BodyPart.shoulders),
        ExerciseListSection(
            exercises: widget.tricepsExercises, bodyPart: BodyPart.triceps),
        ExerciseListSection(
            exercises: widget.legsExercises, bodyPart: BodyPart.legs),
      ],
    );
  }
}

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../app_constants.dart';
import '../../dtos/exercise_in_workout_dto.dart';

class ReOrderExercises extends StatefulWidget {
  final List<ExerciseInWorkoutDto> exercises;

  const ReOrderExercises({super.key, required this.exercises});

  @override
  State<ReOrderExercises> createState() => _ReOrderExercisesState();
}

class _ReOrderExercisesState extends State<ReOrderExercises> {
  bool _hasReOrdered = false;
  late List<ExerciseInWorkoutDto> _reOrderedExercises;

  void _reOrderExercises({required int oldIndex, required int newIndex}) {
    setState(() {
      _hasReOrdered = true;

      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final ExerciseInWorkoutDto item = _reOrderedExercises.removeAt(oldIndex);
      _reOrderedExercises.insert(newIndex, item);
    });
  }

  List<Widget> _exerciseToListTile() {
    return _reOrderedExercises
        .mapIndexed((index, exercise) => CupertinoListTile(
              key: Key("$index"),
              title: Text(exercise.exercise.name, style: Theme.of(context).textTheme.bodyLarge),
              trailing: const Icon(
                CupertinoIcons.bars,
                color: CupertinoColors.white,
              ),
            ))
        .toList();
  }

  /// Navigate to previous screen
  void _saveReOrdering() {
    Navigator.of(context).pop(_reOrderedExercises);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: tealBlueDark,
        middle: const Text(
          "Reorder",
          style: TextStyle(color: CupertinoColors.white),
        ),
        trailing: GestureDetector(
            onTap: _saveReOrdering,
            child: _hasReOrdered
                ? const Text(
                    "Save",
                    style: TextStyle(color: CupertinoColors.white),
                  )
                : const SizedBox.shrink()),
      ),
      child: ReorderableListView(
          children: _exerciseToListTile(),
          onReorder: (int oldIndex, int newIndex) => _reOrderExercises(oldIndex: oldIndex, newIndex: newIndex)),
    );
  }

  @override
  void initState() {
    super.initState();
    _reOrderedExercises = widget.exercises;
  }
}

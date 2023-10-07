import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';
import 'package:tracker_app/dtos/exercise_in_workout_dto.dart';
import '../widgets/workout/exercise_in_workout_list_section.dart';
import 'exercise_library_screen.dart';

const double _kItemExtent = 32.0;

class NewWorkoutScreen extends StatefulWidget {
  const NewWorkoutScreen({super.key});

  @override
  State<NewWorkoutScreen> createState() => _NewWorkoutScreenState();
}

class _NewWorkoutScreenState extends State<NewWorkoutScreen> {
  List<ExerciseInWorkoutDto> _exercisesInWorkout = [];

  List<ExerciseInWorkoutDto> _whereExercisesToSuperSetWith({required ExerciseInWorkoutDto firstSuperSetExercise}) {
    return _exercisesInWorkout
        .whereNot((exercisesInWorkout) =>
            exercisesInWorkout.exercise == firstSuperSetExercise.exercise)
        .toList();
  }

  void _showExercisesInWorkoutPicker(
      {required ExerciseInWorkoutDto firstSuperSetExercise}) {
    final exercisesToSuperSetWith = _whereExercisesToSuperSetWith(
        firstSuperSetExercise: firstSuperSetExercise);
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        // The Bottom margin is provided to align the popup above the system navigation bar.
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // Provide a background color for the popup.
        color: Colors.transparent,
        // Use a SafeArea widget to avoid system overlaps.
        child: SafeArea(
          top: false,
          child: CupertinoPicker(
            magnification: 1.22,
            squeeze: 1.2,
            useMagnifier: true,
            itemExtent: _kItemExtent,
            onSelectedItemChanged: (int selectedExerciseIndex) {
              _markAsSuperSet(firstSuperSetExercise: firstSuperSetExercise, secondSuperSetExercise: exercisesToSuperSetWith[selectedExerciseIndex]);
            },
            children: exercisesToSuperSetWith.map((exerciseInWorkout) => Text(exerciseInWorkout.exercise.name, style: const TextStyle(color: CupertinoColors.white))).toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _showListOfExercisesInLibrary(BuildContext context) async {
    final selectedExercises = await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return ExerciseLibraryScreen(
            preSelectedExercises: _exercisesInWorkout
                .map((exerciseInWorkout) => exerciseInWorkout.exercise)
                .toList());
      },
    ) as List<ExerciseDto>?;

    if (selectedExercises != null) {
      setState(() {
        _exercisesInWorkout.addAll(selectedExercises
            .map((exercise) =>
                ExerciseInWorkoutDto(exercise: exercise, procedures: []))
            .toList());
      });
    }
  }

  List<ExerciseInWorkoutListSection>
      _exercisesToExerciseInWorkoutListSection() {
    return _exercisesInWorkout
        .map((exercisesInWorkout) => ExerciseInWorkoutListSection(
              exerciseInWorkoutDto: exercisesInWorkout,
              onSuperSetExercises:
                  (ExerciseInWorkoutDto firstSuperSetExercise) {
                _showExercisesInWorkoutPicker(
                    firstSuperSetExercise: firstSuperSetExercise);
              },
            ))
        .toList();
  }

  void _navigateBack() {
    Navigator.of(context).pop();
  }

  void _markAsSuperSet(
      {required ExerciseInWorkoutDto firstSuperSetExercise,
      required ExerciseInWorkoutDto secondSuperSetExercise}) {
    setState(() {
      _exercisesInWorkout = _exercisesInWorkout.map((exerciseInWorkout) {
        if (exerciseInWorkout.exercise == firstSuperSetExercise.exercise ||
            exerciseInWorkout.exercise == secondSuperSetExercise.exercise) {
          exerciseInWorkout.isSuperSet = true;
          return exerciseInWorkout;
        }
        return exerciseInWorkout;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text(
            'New Workout',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: GestureDetector(
              onTap: _navigateBack,
              child: const Icon(
                CupertinoIcons.check_mark_circled,
                size: 24,
              )),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ..._exercisesToExerciseInWorkoutListSection(),
                GestureDetector(
                    onTap: () => _showListOfExercisesInLibrary(context),
                    child: const Center(
                        child: Text(
                      "Add new exercise",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ))),
              ],
            ),
          ),
        ));
  }
}

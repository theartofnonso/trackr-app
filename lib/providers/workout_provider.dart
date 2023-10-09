import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:tracker_app/dtos/procedure_dto.dart';
import 'package:tracker_app/dtos/workout_dto.dart';

import '../dtos/exercise_dto.dart';
import '../dtos/exercise_in_workout_dto.dart';

class WorkoutProvider with ChangeNotifier {

  List<WorkoutDto> workouts = [];

  final List<ExerciseInWorkoutDto> exercisesInWorkout = [];

  void addExercises({required List<ExerciseDto> exercises}) {
    final exercisesToAdd = exercises
        .map((exercise) => ExerciseInWorkoutDto(exercise: exercise))
        .toList();
    exercisesInWorkout.addAll(exercisesToAdd);
    notifyListeners();
  }

  void removeExercise({required ExerciseInWorkoutDto exerciseToRemove}) {
    exercisesInWorkout.remove(exerciseToRemove);
    if (exerciseToRemove.isSuperSet) {
      removeSuperSet(superSetId: exerciseToRemove.superSetId);
    } else {
      notifyListeners();
    }
  }

  void updateNotes(
      {required ExerciseInWorkoutDto exerciseInWorkout,
        required String notes}) {
    final index = exercisesInWorkout.indexWhere((exerciseInWorkout) =>
    exerciseInWorkout.exercise == exerciseInWorkout.exercise);
    exercisesInWorkout[index].notes = notes;
  }

  void addNewWorkingSet({required ExerciseInWorkoutDto exerciseInWorkout}) {
    final index = exercisesInWorkout.indexWhere((exerciseInWorkout) =>
    exerciseInWorkout.exercise == exerciseInWorkout.exercise);
    exercisesInWorkout[index].workingProcedures.add(ProcedureDto());
  }

  void removeWorkingSet(
      {required ExerciseInWorkoutDto exerciseInWorkout, required int index}) {
    final index = exercisesInWorkout.indexWhere((exerciseInWorkout) =>
    exerciseInWorkout.exercise == exerciseInWorkout.exercise);
    exercisesInWorkout[index].workingProcedures.removeAt(index);
  }

  void addNewWarmupSet({required ExerciseInWorkoutDto exerciseInWorkout}) {
    final index = exercisesInWorkout.indexWhere((exerciseInWorkout) =>
    exerciseInWorkout.exercise == exerciseInWorkout.exercise);
    exercisesInWorkout[index].warmupProcedures.add(ProcedureDto());
  }

  void removeWarmupSet(
      {required ExerciseInWorkoutDto exerciseInWorkout, required int index}) {
    final index = exercisesInWorkout.indexWhere((exerciseInWorkout) =>
    exerciseInWorkout.exercise == exerciseInWorkout.exercise);
    exercisesInWorkout[index].warmupProcedures.removeAt(index);
  }

  void updateReps(
      {required ExerciseInWorkoutDto exerciseInWorkout,
        required int setIndex,
        required int repCount,
        required bool isWarmup}) {
    final index = exercisesInWorkout.indexWhere((exerciseInWorkout) =>
    exerciseInWorkout.exercise == exerciseInWorkout.exercise);
    if (exerciseInWorkout.exercise.name == exerciseInWorkout.exercise.name) {
      if (isWarmup) {
        exercisesInWorkout[index].warmupProcedures[setIndex].repCount =
            repCount;
      } else {
        exercisesInWorkout[index].workingProcedures[setIndex].repCount =
            repCount;
      }
    }
  }

  void updateWeight(
      {required ExerciseInWorkoutDto exerciseInWorkout,
        required int setIndex,
        required int weight,
        required bool isWarmup}) {
    final index = exercisesInWorkout.indexWhere((exerciseInWorkout) =>
    exerciseInWorkout.exercise == exerciseInWorkout.exercise);
    if (exerciseInWorkout.exercise.name == exerciseInWorkout.exercise.name) {
      if (isWarmup) {
        exercisesInWorkout[index].warmupProcedures[setIndex].weight = weight;
      } else {
        exercisesInWorkout[index].workingProcedures[setIndex].weight = weight;
      }
    }
  }

  bool canSuperSet() {
    return exercisesInWorkout
        .whereNot((exerciseInWorkout) => exerciseInWorkout.isSuperSet)
        .toList()
        .length >
        1;
  }

  void addSuperSets(
      {required ExerciseInWorkoutDto firstExercise,
      required ExerciseInWorkoutDto secondExercise}) {
    final id = "id_${DateTime.now().millisecond}";

    final firstIndex = exercisesInWorkout.indexWhere((exerciseInWorkout) =>
        exerciseInWorkout.exercise.name == firstExercise.exercise.name);
    final secondIndex = exercisesInWorkout.indexWhere((exerciseInWorkout) =>
        exerciseInWorkout.exercise.name == secondExercise.exercise.name);

    exercisesInWorkout[firstIndex].isSuperSet = true;
    exercisesInWorkout[firstIndex].superSetId = id;

    exercisesInWorkout[secondIndex].isSuperSet = true;
    exercisesInWorkout[secondIndex].superSetId = id;

    notifyListeners();
  }

  void removeSuperSet({required String superSetId}) {
    for (var exerciseInWorkout in exercisesInWorkout) {
      if (exerciseInWorkout.superSetId == superSetId) {
        final index = exercisesInWorkout.indexWhere(
            (exerciseInWorkout) => exerciseInWorkout.superSetId == superSetId);
        exercisesInWorkout[index].isSuperSet = false;
        exercisesInWorkout[index].superSetId = "";
      }
    }
    notifyListeners();
  }

  ExerciseInWorkoutDto whereOtherSuperSet(
      {required ExerciseInWorkoutDto firstExercise}) {
    return exercisesInWorkout.firstWhere((exerciseInWorkout) =>
        exerciseInWorkout.superSetId == firstExercise.superSetId &&
        exerciseInWorkout.exercise != firstExercise.exercise);
  }

  List<ExerciseInWorkoutDto> whereOtherExercisesToSuperSetWith(
      {required ExerciseInWorkoutDto firstExercise}) {
    return exercisesInWorkout
        .whereNot((exerciseInWorkout) =>
            exerciseInWorkout.exercise == firstExercise.exercise ||
            exerciseInWorkout.isSuperSet)
        .toList();
  }

  void createWorkout({required String name, required String notes}) {
    final workout = WorkoutDto(name: name, notes: notes, exercises: exercisesInWorkout);
    workouts.add(workout);
    exercisesInWorkout.clear();
  }
}



import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:tracker_app/dtos/procedure_dto.dart';

import '../dtos/exercise_dto.dart';
import '../dtos/exercise_in_workout_dto.dart';
import '../dtos/workout_dto.dart';

class ExerciseInWorkoutProvider with ChangeNotifier {

  final List<WorkoutDto> _workouts = [];

  List<WorkoutDto> get workouts => _workouts;

  final List<ExerciseInWorkoutDto> _exercisesInWorkout = [];

  List<ExerciseInWorkoutDto> get exercisesInWorkout => _exercisesInWorkout;

  void addExercises({required List<ExerciseDto> exercises}) {
    final exercisesToAdd = exercises
        .map((exercise) => ExerciseInWorkoutDto(exercise: exercise))
        .toList();
    _exercisesInWorkout.addAll(exercisesToAdd);
    notifyListeners();
  }

  void removeExercise({required ExerciseInWorkoutDto exerciseToRemove}) {
    _exercisesInWorkout.remove(exerciseToRemove);
    if (exerciseToRemove.isSuperSet) {
      removeSuperSet(superSetId: exerciseToRemove.superSetId);
    } else {
      notifyListeners();
    }
  }

  void updateNotes(
      {required ExerciseInWorkoutDto exerciseInWorkout,
        required String notes}) {
    final index = _exercisesInWorkout.indexWhere((exerciseInWorkout) =>
    exerciseInWorkout.exercise == exerciseInWorkout.exercise);
    _exercisesInWorkout[index].notes = notes;
  }

  void addNewWorkingSet({required ExerciseInWorkoutDto exerciseInWorkout}) {
    final index = _exercisesInWorkout.indexWhere((exerciseInWorkout) =>
    exerciseInWorkout.exercise == exerciseInWorkout.exercise);
    _exercisesInWorkout[index].workingProcedures.add(ProcedureDto());
  }

  void removeWorkingSet(
      {required ExerciseInWorkoutDto exerciseInWorkout, required int index}) {
    final index = _exercisesInWorkout.indexWhere((exerciseInWorkout) =>
    exerciseInWorkout.exercise == exerciseInWorkout.exercise);
    _exercisesInWorkout[index].workingProcedures.removeAt(index);
  }

  void addNewWarmupSet({required ExerciseInWorkoutDto exerciseInWorkout}) {
    final index = _exercisesInWorkout.indexWhere((exerciseInWorkout) =>
    exerciseInWorkout.exercise == exerciseInWorkout.exercise);
    _exercisesInWorkout[index].warmupProcedures.add(ProcedureDto());
  }

  void removeWarmupSet(
      {required ExerciseInWorkoutDto exerciseInWorkout, required int index}) {
    final index = _exercisesInWorkout.indexWhere((exerciseInWorkout) =>
    exerciseInWorkout.exercise == exerciseInWorkout.exercise);
    _exercisesInWorkout[index].warmupProcedures.removeAt(index);
  }

  void updateReps(
      {required ExerciseInWorkoutDto exerciseInWorkout,
        required int setIndex,
        required int repCount,
        required bool isWarmup}) {
    final index = _exercisesInWorkout.indexWhere((exerciseInWorkout) =>
    exerciseInWorkout.exercise == exerciseInWorkout.exercise);
    if (exerciseInWorkout.exercise.name == exerciseInWorkout.exercise.name) {
      if (isWarmup) {
        _exercisesInWorkout[index].warmupProcedures[setIndex].repCount =
            repCount;
      } else {
        _exercisesInWorkout[index].workingProcedures[setIndex].repCount =
            repCount;
      }
    }
  }

  void updateWeight(
      {required ExerciseInWorkoutDto exerciseInWorkout,
        required int setIndex,
        required int weight,
        required bool isWarmup}) {
    final index = _exercisesInWorkout.indexWhere((exerciseInWorkout) =>
    exerciseInWorkout.exercise == exerciseInWorkout.exercise);
    if (exerciseInWorkout.exercise.name == exerciseInWorkout.exercise.name) {
      if (isWarmup) {
        _exercisesInWorkout[index].warmupProcedures[setIndex].weight = weight;
      } else {
        _exercisesInWorkout[index].workingProcedures[setIndex].weight = weight;
      }
    }
  }

  bool canSuperSet() {
    return _exercisesInWorkout
        .whereNot((exerciseInWorkout) => exerciseInWorkout.isSuperSet)
        .toList()
        .length >
        1;
  }

  void addSuperSets(
      {required ExerciseInWorkoutDto firstExercise,
      required ExerciseInWorkoutDto secondExercise}) {
    final id = "id_${DateTime.now().millisecond}";

    final firstIndex = _exercisesInWorkout.indexWhere((exerciseInWorkout) =>
        exerciseInWorkout.exercise.name == firstExercise.exercise.name);
    final secondIndex = _exercisesInWorkout.indexWhere((exerciseInWorkout) =>
        exerciseInWorkout.exercise.name == secondExercise.exercise.name);

    _exercisesInWorkout[firstIndex].isSuperSet = true;
    _exercisesInWorkout[firstIndex].superSetId = id;

    _exercisesInWorkout[secondIndex].isSuperSet = true;
    _exercisesInWorkout[secondIndex].superSetId = id;

    notifyListeners();
  }

  void removeSuperSet({required String superSetId}) {
    for (var exerciseInWorkout in _exercisesInWorkout) {
      if (exerciseInWorkout.superSetId == superSetId) {
        final index = _exercisesInWorkout.indexWhere(
            (exerciseInWorkout) => exerciseInWorkout.superSetId == superSetId);
        _exercisesInWorkout[index].isSuperSet = false;
        _exercisesInWorkout[index].superSetId = "";
      }
    }
    notifyListeners();
  }

  ExerciseInWorkoutDto whereOtherSuperSet(
      {required ExerciseInWorkoutDto firstExercise}) {
    return _exercisesInWorkout.firstWhere((exerciseInWorkout) =>
        exerciseInWorkout.superSetId == firstExercise.superSetId &&
        exerciseInWorkout.exercise != firstExercise.exercise);
  }

  List<ExerciseInWorkoutDto> whereOtherExercisesToSuperSetWith(
      {required ExerciseInWorkoutDto firstExercise}) {
    return _exercisesInWorkout
        .whereNot((exerciseInWorkout) =>
            exerciseInWorkout.exercise == firstExercise.exercise ||
            exerciseInWorkout.isSuperSet)
        .toList();
  }

  void createWorkout({required String name, required String notes, }) {
    final workout = WorkoutDto(name: name, notes: notes, exercises: [..._exercisesInWorkout]);
    _workouts.add(workout);
    _exercisesInWorkout.clear();
    notifyListeners();
  }

}



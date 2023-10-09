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

  void addExercisesInWorkout({required List<ExerciseInWorkoutDto> exercises}) {
    _exercisesInWorkout.addAll(exercises);
  }

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

  int _indexWhereExercise({required ExerciseInWorkoutDto exerciseInWorkout}) {
    return _exercisesInWorkout.indexWhere((item) => item.exercise == exerciseInWorkout.exercise);
  }

  void updateNotes(
      {required ExerciseInWorkoutDto exerciseInWorkout,
        required String notes}) {
    final index = _indexWhereExercise(exerciseInWorkout: exerciseInWorkout);
    _exercisesInWorkout[index].notes = notes;
  }

  void addWorkingSet({required ExerciseInWorkoutDto exerciseInWorkout}) {
    final index = _indexWhereExercise(exerciseInWorkout: exerciseInWorkout);
    _exercisesInWorkout[index].workingProcedures.add(ProcedureDto());
    notifyListeners();
  }

  void removeWorkingSet({required ExerciseInWorkoutDto exerciseInWorkout, required int index}) {
    final index = _indexWhereExercise(exerciseInWorkout: exerciseInWorkout);
    _exercisesInWorkout[index].workingProcedures.removeAt(index);
    notifyListeners();
  }

  void addWarmupSet({required ExerciseInWorkoutDto exerciseInWorkout}) {
    final index = _indexWhereExercise(exerciseInWorkout: exerciseInWorkout);
    _exercisesInWorkout[index].warmupProcedures.add(ProcedureDto());
    notifyListeners();
  }

  void removeWarmupSet({required ExerciseInWorkoutDto exerciseInWorkout, required int index}) {
    final index = _indexWhereExercise(exerciseInWorkout: exerciseInWorkout);
    _exercisesInWorkout[index].warmupProcedures.removeAt(index);
    notifyListeners();
  }

  void updateReps(
      {required ExerciseInWorkoutDto exerciseInWorkout,
        required int setIndex,
        required int repCount,
        required bool isWarmup}) {
    final index = _indexWhereExercise(exerciseInWorkout: exerciseInWorkout);
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
    final index = _indexWhereExercise(exerciseInWorkout: exerciseInWorkout);
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

    final firstIndex = _indexWhereExercise(exerciseInWorkout: firstExercise);
    final secondIndex = _indexWhereExercise(exerciseInWorkout: secondExercise);

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
            (item) => item.superSetId == superSetId);
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

  void createWorkout({required String name, required String notes}) {
    final workout = WorkoutDto(name: name, notes: notes, exercises: [..._exercisesInWorkout]);
    _workouts.add(workout);
    _exercisesInWorkout.clear();
    notifyListeners();
  }

  void updateWorkout({required String id,required String name, required String notes}) {
    final index = _workouts.indexWhere((workout) => workout.id == id);
    _workouts[index] = WorkoutDto(name: name, notes: notes, exercises: [..._exercisesInWorkout]);
    _exercisesInWorkout.clear();
    notifyListeners();
  }

}



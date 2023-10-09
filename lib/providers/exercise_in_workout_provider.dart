import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:tracker_app/dtos/procedure_dto.dart';

import '../dtos/exercise_dto.dart';
import '../dtos/exercise_in_workout_dto.dart';

class ExerciseInWorkoutProvider with ChangeNotifier {
  List<ExerciseInWorkoutDto> exercisesInWorkout = [];

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

  bool canSuperSet() {
    return exercisesInWorkout
            .whereNot((exerciseInWorkout) => exerciseInWorkout.isSuperSet)
            .toList()
            .length >
        1;
  }

  void addNewWorkingSet({required ExerciseInWorkoutDto exerciseInWorkout}) {
    exercisesInWorkout = exercisesInWorkout.map((exerciseInWorkout) {
      if (exerciseInWorkout.exercise.name == exerciseInWorkout.exercise.name) {
        exerciseInWorkout.workingProcedures.add(ProcedureDto());
        return exerciseInWorkout;
      }
      return exerciseInWorkout;
    }).toList();
  }

  void removeWorkingSet(
      {required ExerciseInWorkoutDto exerciseInWorkout, required int index}) {
    exercisesInWorkout = exercisesInWorkout.map((exerciseInWorkout) {
      if (exerciseInWorkout.exercise.name == exerciseInWorkout.exercise.name) {
        exerciseInWorkout.workingProcedures.removeAt(index);
        return exerciseInWorkout;
      }
      return exerciseInWorkout;
    }).toList();
  }

  void addNewWarmupSet({required ExerciseInWorkoutDto exerciseInWorkout}) {
    exercisesInWorkout = exercisesInWorkout.map((exerciseInWorkout) {
      if (exerciseInWorkout.exercise.name == exerciseInWorkout.exercise.name) {
        exerciseInWorkout.warmupProcedures.add(ProcedureDto());
        return exerciseInWorkout;
      }
      return exerciseInWorkout;
    }).toList();
  }

  void removeWarmupSet(
      {required ExerciseInWorkoutDto exerciseInWorkout, required int index}) {
    exercisesInWorkout = exercisesInWorkout.map((exerciseInWorkout) {
      if (exerciseInWorkout.exercise.name == exerciseInWorkout.exercise.name) {
        exerciseInWorkout.warmupProcedures.removeAt(index);
        return exerciseInWorkout;
      }
      return exerciseInWorkout;
    }).toList();
  }

  void updateReps({required ExerciseInWorkoutDto exerciseInWorkout, required int setIndex, required int repCount, required bool isWarmup}) {
    exercisesInWorkout = exercisesInWorkout.map((exerciseInWorkout) {
      if (exerciseInWorkout.exercise.name == exerciseInWorkout.exercise.name) {
        if(isWarmup) {
          exerciseInWorkout.warmupProcedures[setIndex].repCount = repCount;
        } else {
          exerciseInWorkout.workingProcedures[setIndex].repCount = repCount;
        }
        return exerciseInWorkout;
      }
      return exerciseInWorkout;
    }).toList();
  }

  void updateWeight({required ExerciseInWorkoutDto exerciseInWorkout, required int setIndex, required int weight, required bool isWarmup}) {
    exercisesInWorkout = exercisesInWorkout.map((exerciseInWorkout) {
      if (exerciseInWorkout.exercise.name == exerciseInWorkout.exercise.name) {
        if(isWarmup) {
          exerciseInWorkout.warmupProcedures[setIndex].weight = weight;
        } else {
          exerciseInWorkout.workingProcedures[setIndex].weight = weight;
        }
        return exerciseInWorkout;
      }
      return exerciseInWorkout;
    }).toList();
  }
}

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';

import '../enums/exercise_type_enums.dart';
import '../models/Exercise.dart';
import '../shared_prefs.dart';

class ExerciseProvider with ChangeNotifier {
  List<Exercise> _exercises = [];

  UnmodifiableListView<Exercise> get exercises => UnmodifiableListView(_exercises);

  Future<void> listExercises() async {
    _exercises = await Amplify.DataStore.query(Exercise.classType);
    notifyListeners();
  }

  Future<void> saveExercise(
      {required String name,
      required String notes,
      required MuscleGroup primary,
      required ExerciseType type,
      required List<MuscleGroup> secondary}) async {

    final exerciseToCreate = Exercise(
        name: name,
        primaryMuscle: primary.name,
        type: type.name,
        secondaryMuscles: secondary.map((muscleGroup) => muscleGroup.name).toList(),
        createdAt: TemporalDateTime.now(),
        updatedAt: TemporalDateTime.now(), userId: SharedPrefs().userId);
    await Amplify.DataStore.save<Exercise>(exerciseToCreate);
    _exercises.add(exerciseToCreate);
    notifyListeners();
  }

  Future<void> updateExercise({required Exercise exercise}) async {
    final request = ModelMutations.update(exercise);
    final response = await Amplify.API.mutate(request: request).response;
    final updatedExercise = response.data;
    if (updatedExercise != null) {
      final index = _indexWhereExercise(id: exercise.id);
      _exercises[index] = exercise;
      notifyListeners();
    }
  }

  Future<void> removeExercise({required String id}) async {
    final index = _indexWhereExercise(id: id);
    final exerciseToBeRemoved = _exercises[index];
    final request = ModelMutations.delete(exerciseToBeRemoved);
    final response = await Amplify.API.mutate(request: request).response;
    final deletedExercise = response.data;
    if (deletedExercise != null) {
      _exercises.removeAt(index);
      notifyListeners();
    }
  }

  int _indexWhereExercise({required String id}) {
    return _exercises.indexWhere((routine) => routine.id == id);
  }

  Exercise? whereExerciseOrNull({required String exerciseId}) {
    return _exercises.firstWhereOrNull((exercise) => exercise.id == exerciseId);
  }

  void reset() {
    _exercises.clear();
    notifyListeners();
  }
}

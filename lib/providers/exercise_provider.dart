import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';
import 'package:tracker_app/extensions/exercise_extension.dart';

import '../models/Exercise.dart';

class ExerciseProvider with ChangeNotifier {
  List<ExerciseDto> _exercises = [];

  UnmodifiableListView<ExerciseDto> get exercises => UnmodifiableListView(_exercises);

  Future<void> listExercises({List<Exercise>? exercises}) async {
    final queries = exercises ?? await Amplify.DataStore.query(Exercise.classType);
    _exercises = queries.map((exercise) => exercise.dto()).toList();
    notifyListeners();
  }

  Future<void> saveExercise({required ExerciseDto exerciseDto}) async {
    final now = TemporalDateTime.now();

    final exerciseToCreate =
        Exercise(data: jsonEncode(exerciseDto.toJson()), createdAt: now, updatedAt: now);

    await Amplify.DataStore.save<Exercise>(exerciseToCreate);

    _exercises.add(exerciseDto.copyWith(id: exerciseToCreate.id));

    notifyListeners();
  }

  Future<void> updateExercise({required ExerciseDto exercise}) async {
    final result = (await Amplify.DataStore.query(
      Exercise.classType,
      where: Exercise.ID.eq(exercise.id),
    ));

    if (result.isNotEmpty) {
      final oldExercise = result.first;
      final newExercise = oldExercise.copyWith(data: jsonEncode(exercise));
      await Amplify.DataStore.save(newExercise);
      final index = _indexWhereExercise(id: exercise.id);
      _exercises[index] = exercise;
      notifyListeners();
    }
  }

  Future<void> removeExercise({required String id}) async {
    final result = (await Amplify.DataStore.query(
      Exercise.classType,
      where: Exercise.ID.eq(id),
    ));

    if (result.isNotEmpty) {
      final oldTemplate = result.first;
      await Amplify.DataStore.delete(oldTemplate);
      final index = _indexWhereExercise(id: id);
      _exercises.removeAt(index);
      notifyListeners();
    }
  }

  int _indexWhereExercise({required String id}) {
    return _exercises.indexWhere((routine) => routine.id == id);
  }

  ExerciseDto? whereExerciseOrNull({required String exerciseId}) {
    return _exercises.firstWhereOrNull((exercise) => exercise.id == exerciseId);
  }

  void reset() {
    _exercises.clear();
    notifyListeners();
  }
}

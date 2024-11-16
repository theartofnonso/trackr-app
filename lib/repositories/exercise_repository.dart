import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';

import '../dtos/exercise_dto.dart';

class ExerciseRepository {
  final List<ExerciseDTO> _exercises = [];

  UnmodifiableListView<ExerciseDTO> get exercises => UnmodifiableListView(_exercises);

  Future<List<ExerciseDTO>> _loadFromAssets({required String file}) async {
    String jsonString = await rootBundle.loadString('exercises/$file');
    final exerciseJsons = json.decode(jsonString) as List<dynamic>;
    return exerciseJsons.map((json) => ExerciseDTO.fromJson(json)).toList();
  }

  Future<void> loadExercises() async {
    final chestExercises = await _loadFromAssets(file: 'chest_exercises.json');
    final bicepsExercises = await _loadFromAssets(file: 'biceps_exercises.json');
    _exercises.addAll(chestExercises);
    _exercises.addAll(bicepsExercises);
  }

  /// Helper methods

  ExerciseDTO? whereExercise({required String name}) {
    return exercises.firstWhereOrNull((exercise) => exercise.name == name);
  }

  void clear() {
    _exercises.clear();
  }
}

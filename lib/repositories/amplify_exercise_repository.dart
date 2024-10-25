import 'dart:async';
import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';
import 'package:tracker_app/extensions/exercise_extension.dart';

import '../models/Exercise.dart';
import '../shared_prefs.dart';

class AmplifyExerciseRepository {
  List<ExerciseDto> _exercises = [];

  UnmodifiableListView<ExerciseDto> get exercises => UnmodifiableListView(_exercises);

  Future<List<ExerciseDto>> _loadFromAssets({required String file}) async {
    String jsonString = await rootBundle.loadString('exercises/$file');
    final exerciseJsons = json.decode(jsonString) as List<dynamic>;
    return exerciseJsons.map((json) => ExerciseExtension.dtoLocal(json)).toList();
  }

  Future<void> loadLocalExercises() async {
    List<ExerciseDto> exerciseDtos = [];
    final chestExercises = await _loadFromAssets(file: 'chest_exercises.json');
    final shouldersExercises = await _loadFromAssets(file: 'shoulders_exercises.json');
    final bicepsExercises = await _loadFromAssets(file: 'biceps_exercises.json');
    final tricepsExercises = await _loadFromAssets(file: 'triceps_exercises.json');
    final quadricepsExercises = await _loadFromAssets(file: 'quadriceps_exercises.json');
    final hamstringsExercises = await _loadFromAssets(file: 'hamstrings_exercises.json');
    final backExercises = await _loadFromAssets(file: 'back_exercises.json');
    final trapsExercises = await _loadFromAssets(file: 'traps_exercises.json');
    final latsExercises = await _loadFromAssets(file: 'lats_exercises.json');
    final glutesExercises = await _loadFromAssets(file: 'glutes_exercises.json');
    final adductorsExercises = await _loadFromAssets(file: 'adductors_exercises.json');
    final abductorsExercises = await _loadFromAssets(file: 'abductors_exercises.json');
    final absExercises = await _loadFromAssets(file: 'abs_exercises.json');
    final calvesExercises = await _loadFromAssets(file: 'calves_exercises.json');
    final forearmsExercises = await _loadFromAssets(file: 'forearms_exercises.json');
    final neckExercises = await _loadFromAssets(file: 'neck_exercises.json');
    final fullBodyExercises = await _loadFromAssets(file: 'fullbody_exercises.json');

    exerciseDtos.addAll(chestExercises);
    exerciseDtos.addAll(shouldersExercises);
    exerciseDtos.addAll(bicepsExercises);
    exerciseDtos.addAll(tricepsExercises);
    exerciseDtos.addAll(quadricepsExercises);
    exerciseDtos.addAll(hamstringsExercises);
    exerciseDtos.addAll(backExercises);
    exerciseDtos.addAll(trapsExercises);
    exerciseDtos.addAll(latsExercises);
    exerciseDtos.addAll(glutesExercises);
    exerciseDtos.addAll(adductorsExercises);
    exerciseDtos.addAll(abductorsExercises);
    exerciseDtos.addAll(absExercises);
    exerciseDtos.addAll(calvesExercises);
    exerciseDtos.addAll(forearmsExercises);
    exerciseDtos.addAll(neckExercises);
    exerciseDtos.addAll(fullBodyExercises);

    // List<String> withNoVideos = exerciseDtos
    //     .where((exercise) => exercise.video == null && !exercise.owner)
    //     .map((exercise) => exercise.name)
    //     .toList();
    //
    // withNoVideos.forEach((exercise) {
    //   print(exercise);
    // });
    //
    // print(withNoVideos.length);

    _exercises = exerciseDtos.sorted((a, b) => a.name.compareTo(b.name));
  }

  void loadExerciseStream({required List<Exercise> exercises}) {
    final snapshot = exercises.map((exercise) => exercise.dtoUser());
    _exercises.addAll(snapshot);
    _exercises = _exercises.toSet().sorted((a, b) => a.name.compareTo(b.name));
  }

  Future<void> saveExercise({required ExerciseDto exerciseDto}) async {
    final now = TemporalDateTime.now();

    final exerciseToCreate = Exercise(data: jsonEncode(exerciseDto), createdAt: now, updatedAt: now);

    await Amplify.DataStore.save<Exercise>(exerciseToCreate);

    final updatedExerciseWithId = exerciseDto.copyWith(id: exerciseToCreate.id, owner: SharedPrefs().userId);

    _exercises.add(updatedExerciseWithId);
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
      if(index > -1) {
        _exercises[index] = exercise;
      }
    }
  }

  Future<void> removeExercise({required ExerciseDto exercise}) async {
    final result = (await Amplify.DataStore.query(
      Exercise.classType,
      where: Exercise.ID.eq(exercise.id),
    ));

    if (result.isNotEmpty) {
      final oldTemplate = result.first;
      await Amplify.DataStore.delete(oldTemplate);
      final index = _indexWhereExercise(id: exercise.id);
      if(index > -1) {
        _exercises.removeAt(index);
      }
    }
  }

  /// Helper methods

  int _indexWhereExercise({required String id}) {
    return _exercises.indexWhere((routine) => routine.id == id);
  }

  ExerciseDto? whereExercise({required String exerciseId}) {
    return _exercises.firstWhereOrNull((exercise) => exercise.id == exerciseId);
  }

  void clear() {
    _exercises.clear();
  }
}

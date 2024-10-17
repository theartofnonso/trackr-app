import 'dart:async';
import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';
import 'package:tracker_app/extensions/exercise_extension.dart';

import '../enums/exercise_type_enums.dart';
import '../enums/muscle_group_enums.dart';
import '../models/Exercise.dart';

class AmplifyExerciseRepository {
  List<ExerciseDto> _exercises = [];

  UnmodifiableListView<ExerciseDto> get exercises => UnmodifiableListView(_exercises);

  Future<List<ExerciseDto>> _loadFromAssets({required String file}) async {
    String jsonString = await rootBundle.loadString('exercises/$file');
    final exerciseJsons = json.decode(jsonString) as List<dynamic>;
    return exerciseJsons.map((json) {
      final id = json["id"];
      final name = json["name"];
      final primaryMuscleGroupString = json["primaryMuscleGroup"] ?? "";
      final primaryMuscleGroup = MuscleGroup.fromString(primaryMuscleGroupString);
      final secondaryMuscleGroupJson = json["secondaryMuscleGroups"] as List<dynamic>;
      final secondaryMuscleGroups =
      secondaryMuscleGroupJson.map((muscleGroup) => MuscleGroup.fromString(muscleGroup)).toList();
      final typeString = json["type"];
      final video = json["video"];
      final videoUri = video != null ? Uri.parse(video) : null;
      final description = json["description"];
      final creditSource = json["creditSource"];
      final creditSourceUri = video != null ? Uri.parse(creditSource) : null;
      final credit = json["credit"];
      return ExerciseDto(
          id: id,
          name: name,
          primaryMuscleGroup: primaryMuscleGroup,
          secondaryMuscleGroups: secondaryMuscleGroups,
          type: ExerciseType.fromString(typeString),
          video: videoUri,
          description: description,
          creditSource: creditSourceUri,
          credit: credit,
          owner: false);
    }).toList();
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

  void loadExerciseStream({required List<Exercise> exercises}) async {
    final snapshot = exercises.map((exercise) => exercise.dto()).toList();
    _exercises.addAll(snapshot);
  }

  Future<void> saveExercise({required ExerciseDto exerciseDto}) async {
    final now = TemporalDateTime.now();

    final exerciseToCreate = Exercise(data: jsonEncode(exerciseDto), createdAt: now, updatedAt: now);

    await Amplify.DataStore.save<Exercise>(exerciseToCreate);

    _exercises.add(exerciseDto.copyWith(id: exerciseToCreate.id));
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
      _exercises.removeAt(index);
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

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:tracker_app/dtos/db/exercise_dto.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';

class MockExerciseRepository {
  List<ExerciseDto> _localExercises = [];
  List<ExerciseDto> _userExercises = [];

  UnmodifiableListView<ExerciseDto> get exercises => UnmodifiableListView([
        ..._localExercises,
        ..._userExercises
      ].sorted((a, b) => a.name.compareTo(b.name)));

  Future<List<ExerciseDto>> _loadFromAssets({required String file}) async {
    String jsonString = await rootBundle.loadString('exercises/$file');
    final exerciseJsons = json.decode(jsonString) as List<dynamic>;
    return exerciseJsons.map((json) => _dtoLocal(json)).toList();
  }

  Future<void> loadLocalExercises() async {
    List<ExerciseDto> exerciseDtos = [];
    final chestExercises = await _loadFromAssets(file: 'chest_exercises.json');
    final shouldersExercises =
        await _loadFromAssets(file: 'shoulders_exercises.json');
    final bicepsExercises =
        await _loadFromAssets(file: 'biceps_exercises.json');
    final tricepsExercises =
        await _loadFromAssets(file: 'triceps_exercises.json');
    final quadricepsExercises =
        await _loadFromAssets(file: 'quadriceps_exercises.json');
    final hamstringsExercises =
        await _loadFromAssets(file: 'hamstrings_exercises.json');
    final backExercises = await _loadFromAssets(file: 'back_exercises.json');
    final trapsExercises = await _loadFromAssets(file: 'traps_exercises.json');
    final latsExercises = await _loadFromAssets(file: 'lats_exercises.json');
    final glutesExercises =
        await _loadFromAssets(file: 'glutes_exercises.json');
    final adductorsExercises =
        await _loadFromAssets(file: 'adductors_exercises.json');
    final abductorsExercises =
        await _loadFromAssets(file: 'abductors_exercises.json');
    final absExercises = await _loadFromAssets(file: 'abs_exercises.json');
    final calvesExercises =
        await _loadFromAssets(file: 'calves_exercises.json');
    final forearmsExercises =
        await _loadFromAssets(file: 'forearms_exercises.json');
    final neckExercises = await _loadFromAssets(file: 'neck_exercises.json');
    final fullBodyExercises =
        await _loadFromAssets(file: 'fullbody_exercises.json');

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

    _localExercises = exerciseDtos;
  }

  void loadExerciseList({required List<ExerciseDto> exercises}) {
    _userExercises = exercises;
  }

  ExerciseDto? whereExercise({required String exerciseId}) {
    return exercises.firstWhereOrNull((exercise) => exercise.id == exerciseId);
  }

  void clear() {
    _localExercises.clear();
    _userExercises.clear();
  }

  ExerciseDto _dtoLocal(dynamic json) {
    final id = json["id"];
    final name = json["name"];
    final primaryMuscleGroupString = json["primaryMuscleGroup"] ?? "";
    final primaryMuscleGroup = MuscleGroup.fromString(primaryMuscleGroupString);
    final secondaryMuscleGroupJson =
        json["secondaryMuscleGroups"] as List<dynamic>;
    final secondaryMuscleGroups = secondaryMuscleGroupJson
        .map((muscleGroup) => MuscleGroup.fromString(muscleGroup))
        .toList();
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
    );
  }
}

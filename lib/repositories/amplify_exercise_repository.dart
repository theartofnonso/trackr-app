import 'dart:async';
import 'dart:convert';

import 'package:amplify_api/amplify_api.dart';
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

  Future<List<ExerciseDto>> loadExercisesFromAssets({required String file}) async {
    String jsonString = await rootBundle.loadString('exercises/$file');
    final exerciseJsons = json.decode(jsonString) as List<dynamic>;
    return exerciseJsons.map((exerciseJson) {
      final id = exerciseJson["id"];
      final name = exerciseJson["name"];
      final primaryMuscleGroupString = exerciseJson["primaryMuscleGroup"];
      final typeString = exerciseJson["type"];
      final video = exerciseJson["video"];
      final videoUri = video != null ? Uri.parse(video) : null;
      final description = exerciseJson["description"];
      final creditSource = exerciseJson["creditSource"];
      final creditSourceUri = video != null ? Uri.parse(creditSource) : null;
      final credit = exerciseJson["credit"];
      return ExerciseDto(
          id: id,
          name: name,
          primaryMuscleGroup: MuscleGroup.fromString(primaryMuscleGroupString),
          type: ExerciseType.fromString(typeString),
          video: videoUri,
          description: description,
          creditSource: creditSourceUri,
          credit: credit,
          owner: false);
    }).toList();
  }

  Future<void> fetchExercises({required bool firstLaunch}) async {
    List<ExerciseDto> exerciseDtos = [];

    if (firstLaunch) {
      final exercises = await _fetchExercisesCloud();
      exerciseDtos = exercises.map((exercise) => exercise.dto()).toList();
    } else {
      final exercises = await Amplify.DataStore.query(Exercise.classType);
      exerciseDtos = exercises.map((exercise) => exercise.dto()).toList();
    }

    final chestExercises = await loadExercisesFromAssets(file: 'chest_exercises.json');
    final shouldersExercises = await loadExercisesFromAssets(file: 'shoulders_exercises.json');
    final bicepsExercises = await loadExercisesFromAssets(file: 'biceps_exercises.json');
    final tricepsExercises = await loadExercisesFromAssets(file: 'triceps_exercises.json');
    final quadricepsExercises = await loadExercisesFromAssets(file: 'quadriceps_exercises.json');
    final hamstringsExercises = await loadExercisesFromAssets(file: 'hamstrings_exercises.json');
    final backExercises = await loadExercisesFromAssets(file: 'back_exercises.json');
    final trapsExercises = await loadExercisesFromAssets(file: 'traps_exercises.json');
    final latsExercises = await loadExercisesFromAssets(file: 'lats_exercises.json');
    final glutesExercises = await loadExercisesFromAssets(file: 'glutes_exercises.json');
    final adductorsExercises = await loadExercisesFromAssets(file: 'adductors_exercises.json');
    final abductorsExercises = await loadExercisesFromAssets(file: 'abductors_exercises.json');
    final absExercises = await loadExercisesFromAssets(file: 'abs_exercises.json');
    final calvesExercises = await loadExercisesFromAssets(file: 'calves_exercises.json');
    final forearmsExercises = await loadExercisesFromAssets(file: 'forearms_exercises.json');
    final neckExercises = await loadExercisesFromAssets(file: 'neck_exercises.json');
    final fullBodyExercises = await loadExercisesFromAssets(file: 'fullbody_exercises.json');

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

    // List<String> withNoVideos =
    // exerciseDtos.where((exercise) => exercise.video == null && !exercise.owner).map((exercise) => exercise.name).toList();
    //
    // withNoVideos.forEach((exercise) {
    //   print(exercise);
    // });
    //
    // print(withNoVideos.length);

    _exercises = exerciseDtos.sorted((a, b) => a.name.compareTo(b.name));
  }

  Future<List<Exercise>> _fetchExercisesCloud() async {
    final request = ModelQueries.list(Exercise.classType, limit: 999);
    final response = await Amplify.API.query(request: request).response;
    return response.data?.items.whereType<Exercise>().toList() ?? [];
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

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

  StreamSubscription<QuerySnapshot<Exercise>>? _exerciseStream;

  Future<List<ExerciseDto>> loadExercisesFromAssets({required String file}) async {
    String jsonString = await rootBundle.loadString('assets/$file');
    final exerciseJsons = json.decode(jsonString) as List<dynamic>;
    return exerciseJsons.map((exerciseJson) {
      final id = exerciseJson["id"];
      final name = exerciseJson["name"];
      final primaryMuscleGroupString = exerciseJson["primaryMuscleGroup"];
      final typeString = exerciseJson["type"];
      return ExerciseDto(
          id: id,
          name: name,
          primaryMuscleGroup: MuscleGroup.fromString(primaryMuscleGroupString),
          type: ExerciseType.fromString(typeString),
          owner: false);
    }).toList();
  }

  Future<void> fetchExercises({required void Function() onDone}) async {
    final exercises = await Amplify.DataStore.query(Exercise.classType);
    if (exercises.isNotEmpty) {
      _loadExercises(exercises: exercises);
    } else {
      _observeExerciseQuery(onSyncCompleted: onDone);
    }

    final chestExercises = await loadExercisesFromAssets(file: 'chest_exercises.json');
    final shouldersExercises = await loadExercisesFromAssets(file: 'shoulders_exercises.json');
    final bicepsExercises = await loadExercisesFromAssets(file: 'biceps_exercises.json');
    final tricepsExercises = await loadExercisesFromAssets(file: 'triceps_exercises.json');
    final legsExercises = await loadExercisesFromAssets(file: 'legs_exercises.json');
    final backExercises = await loadExercisesFromAssets(file: 'back_exercises.json');
    final glutesExercises = await loadExercisesFromAssets(file: 'glutes_exercises.json');
    final absExercises = await loadExercisesFromAssets(file: 'abs_exercises.json');
    final calvesExercises = await loadExercisesFromAssets(file: 'calves_exercises.json');
    final forearmsExercises = await loadExercisesFromAssets(file: 'forearms_exercises.json');
    final neckExercises = await loadExercisesFromAssets(file: 'neck_exercises.json');
    final fullBodyExercises = await loadExercisesFromAssets(file: 'fullbody_exercises.json');

    _exercises.addAll(chestExercises);
    _exercises.addAll(shouldersExercises);
    _exercises.addAll(bicepsExercises);
    _exercises.addAll(tricepsExercises);
    _exercises.addAll(legsExercises);
    _exercises.addAll(backExercises);
    _exercises.addAll(glutesExercises);
    _exercises.addAll(absExercises);
    _exercises.addAll(calvesExercises);
    _exercises.addAll(forearmsExercises);
    _exercises.addAll(neckExercises);
    _exercises.addAll(fullBodyExercises);

    _exercises.sort((a, b) => a.name.compareTo(b.name));
  }

  void _loadExercises({required List<Exercise> exercises}) {
    _exercises = exercises.map((exercise) => exercise.dto()).sorted((a, b) => a.name.compareTo(b.name));
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

  void _observeExerciseQuery({required void Function() onSyncCompleted}) {
    _exerciseStream = Amplify.DataStore.observeQuery(Exercise.classType).listen((QuerySnapshot<Exercise> snapshot) {
      if (snapshot.items.isNotEmpty) {
        _loadExercises(exercises: snapshot.items);
        _exerciseStream?.cancel();
        onSyncCompleted();
      }
    })
      ..onDone(() {
        _exerciseStream?.cancel();
      });
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

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
  final List<ExerciseDto> _exercises = [];

  UnmodifiableListView<ExerciseDto> get exercises => UnmodifiableListView(_exercises);

  StreamSubscription<QuerySnapshot<Exercise>>? _exerciseStream;

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
      final creditSource = exerciseJson["creditSource"];
      final creditSourceUri = video != null ? Uri.parse(creditSource) : null;
      final credit = exerciseJson["credit"];
      return ExerciseDto(
          id: id,
          name: name,
          primaryMuscleGroup: MuscleGroup.fromString(primaryMuscleGroupString),
          type: ExerciseType.fromString(typeString),
          video: videoUri,
          creditSource: creditSourceUri,
          credit: credit,
          owner: false);
    }).toList();
  }

  Future<void> fetchExercises({required void Function() onDone}) async {
    // final exercises = await Amplify.DataStore.query(Exercise.classType);
    // if (exercises.isNotEmpty) {
    //   _loadUserExercises(exercises: exercises);
    // } else {
    //   _observeExerciseQuery(onSyncCompleted: onDone);
    // }

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

    _exercises.addAll(chestExercises);
    _exercises.addAll(shouldersExercises);
    _exercises.addAll(bicepsExercises);
    _exercises.addAll(tricepsExercises);
    _exercises.addAll(quadricepsExercises);
    _exercises.addAll(hamstringsExercises);
    _exercises.addAll(backExercises);
    _exercises.addAll(trapsExercises);
    _exercises.addAll(latsExercises);
    _exercises.addAll(glutesExercises);
    _exercises.addAll(adductorsExercises);
    _exercises.addAll(abductorsExercises);
    _exercises.addAll(absExercises);
    _exercises.addAll(calvesExercises);
    _exercises.addAll(forearmsExercises);
    _exercises.addAll(neckExercises);
    _exercises.addAll(fullBodyExercises);

    final temp = _exercises.where((element) => element.video == null).toList();
    temp.forEach((element) {
      print(element.name);
    });

    print(temp.length);

    _exercises.sort((a, b) => a.name.compareTo(b.name));
  }

  void _loadUserExercises({required List<Exercise> exercises}) {
    final userExercises = exercises.map((exercise) => exercise.dto()).sorted((a, b) => a.name.compareTo(b.name));
    _exercises.addAll(userExercises);
    _exercises.sort((a, b) => a.name.compareTo(b.name));
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
        _loadUserExercises(exercises: snapshot.items);
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

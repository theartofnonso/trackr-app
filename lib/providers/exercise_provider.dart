import 'dart:collection';
import 'dart:convert';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../models/BodyPart.dart';
import '../models/Exercise.dart';

class ExerciseProvider with ChangeNotifier {
  List<Exercise> _exercises = [];

  UnmodifiableListView<Exercise> get exercises => UnmodifiableListView(_exercises);

  Future<void> listExercises() async {
    final request = ModelQueries.list(Exercise.classType, limit: 1000);
    final response = await Amplify.API.query(request: request).response;

    final items = response.data?.items.whereType<Exercise>().toList();
    if (items != null) {
      _exercises = items;
    }
  }

  Future<void> uploadExercises() async {
    // final exercise = Exercise(name: "Smith Machine Lunge", primary: ['Quads', 'Glutes', 'Adductors'], secondary: [], bodyPart: BodyPart.Legs, createdAt: TemporalDateTime.now(), updatedAt: TemporalDateTime.now());
    // final request = ModelMutations.create(exercise);
    // final result = await Amplify.API.mutate(request: request).response;
    // print(result);

    // var file = '/Users/nonsobiose/IdeaProjects/tracker_app/.xlsx';
    // var bytes = File(file).readAsBytesSync();
    // var excel = Excel.decodeBytes(bytes);

    // final createdAt = TemporalDateTime.now();
    // final updatedAt = TemporalDateTime.now();
    // for (var table in excel.tables.keys) {
    //   print(excel.tables[table]?.maxRows);
    //   for (var row in excel.tables[table]!.rows) {
    //     final name = row.first?.value.toString();
    //     final primary = row[1]?.value.toString().split(",").map((item) => item.trim()).toList();
    //     final secondary = row[2]?.value != null ? row[2]?.value.toString().split(",").map((item) => item.trim()).toList() : <String>[];
    //     final exercise = Exercise(name: name!, primary: primary!, secondary: secondary!, bodyPart: BodyPart.Abs, createdAt: createdAt, updatedAt: updatedAt);
    //     //print(exercise);
    //     final request = ModelMutations.create(exercise);
    //     try {
    //       final result = await Amplify.API.mutate(request: request).response;
    //       print(result);
    //     } catch(e) {
    //       print(e);
    //     }
    //   }
    // }
  }

  // Future<void> parseExercises() async {
  //   final jsonString = '''''';
  //
  //   final jsonList = LineSplitter.split(jsonString);
  //   final exercises = jsonList.map((line) => fromJson(jsonDecode(line)['Item'])).toList();
  //   for(Exercise exercise in exercises) {
  //     final request = ModelMutations.create(exercise);
  //     try {
  //       final result = await Amplify.API.mutate(request: request).response;
  //       print(result);
  //     } catch(e) {
  //       print(e);
  //     }
  //   }
  // }

  Exercise fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id']['S'],
      name: json['name']?['S'],
      primary: List<String>.from(json['primary']['L']?.map((item) => item['S']) ?? []),
      secondary: List<String>.from(json['secondary']['L']?.map((item) => item['S']) ?? []),
      bodyPart: BodyPart.values.firstWhere(
        (e) => e.toString().split('.').last == json['bodyPart']['S'],
        orElse: () => throw Exception('Invalid body part'),
      ),
      asset: "https://usetracker.xyz",
      notes: "",
      createdAt: TemporalDateTime.now(),
      updatedAt: TemporalDateTime.now(),
    );
  }

  Future<void> saveExercise({required String id, required String name, required BodyPart bodyPart}) async {
    // final exerciseToSave =
    //     Exercise(name: name, bodyPart: bodyPart, createdAt: TemporalDateTime.now(), updatedAt: TemporalDateTime.now());
    // await Amplify.DataStore.save<Exercise>(exerciseToSave);
    // _exercises.add(exerciseToSave);
    notifyListeners();
  }

  Exercise whereExercise({required String exerciseId}) {
    return _exercises.firstWhere((exercise) => exercise.id == exerciseId);
  }
}

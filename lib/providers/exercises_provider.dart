import 'dart:collection';
import 'dart:io';
import 'package:amplify_api/amplify_api.dart';
import 'package:path/path.dart';
import 'package:excel/excel.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';

import '../models/BodyPart.dart';
import '../models/Exercise.dart';

class ExerciseProvider with ChangeNotifier {
  final List<Exercise> _exercises = [];

  UnmodifiableListView<Exercise> get exercises => UnmodifiableListView(_exercises);

  void listExercises() async {
    final request = ModelQueries.list(Exercise.classType);
    final response = await Amplify.API.query(request: request).response;

    final items = response.data?.items.whereType<Exercise>().toList();

    if (items != null) {
      _exercises.addAll(items);
    }

    notifyListeners();
  }

  // void uploadExercises() async {
  //   var file = '/Users/nonsobiose/IdeaProjects/tracker_app/';
  //   var bytes = File(file).readAsBytesSync();
  //   var excel = Excel.decodeBytes(bytes);
  //
  //   final createdAt = TemporalDateTime.now();
  //   final updatedAt = TemporalDateTime.now();
  //   for (var table in excel.tables.keys) {
  //     print(excel.tables[table]?.maxRows);
  //     for (var row in excel.tables[table]!.rows) {
  //       final name = row.first?.value.toString();
  //       final primary = row[1]?.value.toString().split(",").map((item) => item.trim()).toList();
  //       final secondary = row[2]?.value.toString().split(",").map((item) => item.trim()).toList();
  //       final exercise = Exercise(name: name!, primary: primary!, secondary: secondary!, bodyPart: BodyPart.Chest, createdAt: createdAt, updatedAt: updatedAt);
  //       final request = ModelMutations.create(exercise);
  //       try {
  //         final result = await Amplify.API.mutate(request: request).response;
  //         print(result);
  //       } catch(e) {
  //         print(e);
  //       }
  //     }
  //   }
  //
  // }

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

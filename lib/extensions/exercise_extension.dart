import 'dart:convert';

import 'package:tracker_app/dtos/exercise_dto.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/models/ModelProvider.dart';

import '../enums/exercise_type_enums.dart';

extension ExerciseExtension on Exercise {

  ExerciseDto dto() {
    final dataJson = jsonDecode(data);

    final name = dataJson["name"] ?? "";
    final notes = dataJson["notes"] ?? "";
    final primaryMuscleGroup = dataJson["primaryMuscleGroup"] ?? "";
    final secondaryMuscleGroupJsons = dataJson["secondaryMuscleGroups"] as List<dynamic>;
    final secondaryMuscleGroups = secondaryMuscleGroupJsons.map((json) => MuscleGroup.fromString(jsonDecode(json))).toList();
    final typeJson = dataJson["type"] ?? "";
    final type = ExerciseType.fromString(typeJson);

    return ExerciseDto(
      id: id,
      name: name,
      notes: notes,
      primaryMuscleGroup: MuscleGroup.fromString(primaryMuscleGroup),
      secondaryMuscleGroups: secondaryMuscleGroups,
      type: type);

  }

}
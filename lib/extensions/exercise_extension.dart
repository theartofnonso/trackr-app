import 'dart:convert';

import 'package:tracker_app/dtos/exercise_dto.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/models/ModelProvider.dart';

import '../enums/exercise_type_enums.dart';

extension ExerciseExtension on Exercise {
  ExerciseDto dto() {
    final dataJson = jsonDecode(data);
    final name = dataJson["name"] ?? "";
    final primaryMuscleGroup = dataJson["primaryMuscleGroup"] ?? "";
    final typeJson = dataJson["type"] ?? "";
    final type = ExerciseType.fromString(typeJson);

    print("ExerciseExtension: $id, $primaryMuscleGroup, $typeJson, $type");

    return ExerciseDto(id: id, name: name, primaryMuscleGroup: MuscleGroup.fromString(primaryMuscleGroup), type: type);
  }
}

import 'dart:convert';

import 'package:tracker_app/dtos/exercise_dto.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/models/ModelProvider.dart';

import '../enums/exercise_type_enums.dart';
import '../enums/training_position_enum.dart';

extension ExerciseExtension on Exercise {
  ExerciseDto dto() {
    final json = jsonDecode(data);
    final name = json["name"] ?? "";
    final primaryMuscleGroupString = json["primaryMuscleGroup"] ?? "";
    final primaryMuscleGroup = MuscleGroup.fromString(primaryMuscleGroupString);
    final secondaryMuscleGroupJson = json["secondaryMuscleGroups"] as List<dynamic>;
    final secondaryMuscleGroups =
    secondaryMuscleGroupJson.map((muscleGroup) => MuscleGroup.fromString(muscleGroup)).toList();
    final typeJson = json["type"] ?? "";
    final trainingPositionString = json["trainingPosition"] ?? "";
    final trainingPosition = TrainingPosition.fromString(trainingPositionString);
    final type = ExerciseType.fromString(typeJson);
    final user = owner != null;

    return ExerciseDto(
        id: id,
        name: name,
        primaryMuscleGroup: primaryMuscleGroup,
        secondaryMuscleGroups: secondaryMuscleGroups,
        trainingPosition: trainingPosition,
        type: type,
        owner: user);
  }
}

import 'package:tracker_app/dtos/exercise_dto.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';

import '../enums/exercise/set_type_enums.dart';

class ExerciseVariantDTO {
  final String baseExerciseId;
  final String name;
  final List<MuscleGroup> primaryMuscleGroups;
  final List<MuscleGroup> secondaryMuscleGroups;
  final Map<String, ExerciseConfig> configurations;

  ExerciseVariantDTO(
      {required this.baseExerciseId,
      required this.name,
      required this.primaryMuscleGroups,
      required this.secondaryMuscleGroups,
      required this.configurations});

  Map<String, dynamic> toJson() {
    return {
      'base_exercise_id': baseExerciseId,
      'name': name,
      'primary_muscle_groups': secondaryMuscleGroups.map((muscleGroup) => muscleGroup.name).toList(),
      'secondary_muscle_groups': secondaryMuscleGroups.map((muscleGroup) => muscleGroup.name).toList(),
      'configurations': configurations,
    };
  }

  factory ExerciseVariantDTO.fromJson(Map<String, dynamic> json) {
    final id = json["base_exercise_id"];
    final name = json["name"];
    final primaryMuscleGroups = (json["primary_muscle_groups"] as List<dynamic>)
        .map((muscleGroup) => MuscleGroup.fromJson(muscleGroup))
        .toList();
    final secondaryMuscleGroups = (json["secondary_muscle_groups"] as List<dynamic>)
        .map((muscleGroup) => MuscleGroup.fromJson(muscleGroup))
        .toList();
    final configurations = (json['configurations'] as Map<String, dynamic>)
        .map((key, value) => MapEntry(key, ExerciseConfig.fromJson(value)));

    return ExerciseVariantDTO(
        baseExerciseId: id,
        name: name,
        primaryMuscleGroups: primaryMuscleGroups,
        secondaryMuscleGroups: secondaryMuscleGroups,
        configurations: configurations);
  }

  dynamic getConfigurationValue(String key) {
    if (configurations.containsKey(key)) {
      return configurations[key];
    } else {
      throw ArgumentError('Configuration key "$key" does not exist in "$name".');
    }
  }

  SetType getSetTypeConfiguration(String key) {
    if (configurations.containsKey(key)) {
      return configurations[key] as SetType;
    } else {
      throw ArgumentError('Configuration key "$key" does not exist in "$name".');
    }
  }

  @override
  String toString() {
    return 'ExerciseVariantDTO{id: $baseExerciseId, name: $name, primaryMuscleGroups: ${primaryMuscleGroups.map((muscleGroup) => muscleGroup.name).join(", ")}, secondaryMuscleGroups: ${secondaryMuscleGroups.map((muscleGroup) => muscleGroup.name).join(", ")}, configurations: $configurations';
  }
}

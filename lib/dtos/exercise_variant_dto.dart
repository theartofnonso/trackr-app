import 'package:tracker_app/dtos/abstract_class/exercise_dto.dart';
import 'package:tracker_app/enums/exercise/exercise_equipment_enum.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';

import '../enums/exercise/exercise_configuration_key.dart';
import '../enums/exercise/set_type_enums.dart';

class ExerciseVariantDTO {
  final String baseExerciseId;
  final String name;
  final List<MuscleGroup> primaryMuscleGroups;
  final List<MuscleGroup> secondaryMuscleGroups;
  final Map<ExerciseConfigurationKey, ExerciseConfigValue> configurations;

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
      'primary_muscle_groups': primaryMuscleGroups.map((muscleGroup) => muscleGroup.name).toList(),
      'secondary_muscle_groups': secondaryMuscleGroups.map((muscleGroup) => muscleGroup.name).toList(),
      'configurations': configurations.map((key, value) => MapEntry(
            key.toJson(),
            value.toJson(),
          ))
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
    final configurationsJsons = (json['configurations'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    Map<ExerciseConfigurationKey, ExerciseConfigValue> configurations = {};
    if (configurationsJsons.isNotEmpty) {
      configurations = configurationsJsons.map(
            (key, value) => MapEntry(ExerciseConfigurationKey.fromJson(key), ExerciseConfigValue.fromJson(value)),
      );
    }
    return ExerciseVariantDTO(
        baseExerciseId: id,
        name: name,
        primaryMuscleGroups: primaryMuscleGroups,
        secondaryMuscleGroups: secondaryMuscleGroups,
        configurations: configurations);
  }

  ExerciseConfigValue getConfigurationValue(ExerciseConfigurationKey key) {
    if (configurations.containsKey(key)) {
      return configurations[key]!;
    } else {
      throw ArgumentError('Configuration key "$key" does not exist in "$name".');
    }
  }

  SetType getSetTypeConfiguration() => configurations[ExerciseConfigurationKey.setType] as SetType;

  ExerciseEquipment getExerciseEquipmentConfiguration() =>
      configurations[ExerciseConfigurationKey.equipment] as ExerciseEquipment;

  ExerciseVariantDTO copyWith({
    String? baseExerciseId,
    String? name,
    List<MuscleGroup>? primaryMuscleGroups,
    List<MuscleGroup>? secondaryMuscleGroups,
    Map<ExerciseConfigurationKey, ExerciseConfigValue>? configurations,
  }) {
    return ExerciseVariantDTO(
      baseExerciseId: baseExerciseId ?? this.baseExerciseId,
      name: name ?? this.name,
      primaryMuscleGroups: primaryMuscleGroups ?? this.primaryMuscleGroups,
      secondaryMuscleGroups: secondaryMuscleGroups ?? this.secondaryMuscleGroups,
      configurations: configurations ?? this.configurations,
    );
  }

  @override
  String toString() {
    return 'ExerciseVariantDTO{id: $baseExerciseId, name: $name, primaryMuscleGroups: ${primaryMuscleGroups.map((muscleGroup) => muscleGroup.name).join(", ")}, secondaryMuscleGroups: ${secondaryMuscleGroups.map((muscleGroup) => muscleGroup.name).join(", ")}, configurations: $configurations';
  }
}

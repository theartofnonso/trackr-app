import 'dart:convert';

import 'package:tracker_app/enums/exercise/core_movements_enum.dart';
import 'package:tracker_app/enums/exercise/exercise_equipment_enum.dart';
import 'package:tracker_app/enums/exercise/exercise_metrics_enums.dart';
import 'package:tracker_app/enums/exercise/exercise_modality_enum.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';

class ExerciseDTO {
  final String name;
  final String description;
  final ExerciseMetric metric;
  final ExerciseModality modality;
  final ExerciseEquipment equipment;
  final List<MuscleGroup> primaryMuscleGroups;
  final List<MuscleGroup> secondaryMuscleGroups;
  final CoreMovement movement;

  ExerciseDTO(
      {required this.name,
      required this.description,
      required this.metric,
      required this.modality,
      required this.equipment,
      required this.primaryMuscleGroups,
      required this.secondaryMuscleGroups,
      required this.movement});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'primary_muscle_groups': secondaryMuscleGroups.map((muscleGroup) => jsonEncode(muscleGroup.name)).toList(),
      'secondary_muscle_groups': secondaryMuscleGroups.map((muscleGroup) => jsonEncode(muscleGroup.name)).toList(),
      'metric': metric.name,
      'modality': modality.name,
      'equipment': equipment.name,
      'movement': movement.name
    };
  }

  factory ExerciseDTO.fromJson(Map<String, dynamic> json) {
    final name = json["name"];
    final description = json["description"];
    final metric = ExerciseMetric.fromString(json["metric"]);
    final movement = CoreMovement.fromString(json["movement"]);
    final modality = ExerciseModality.fromString(json["modality"]);
    final equipment = ExerciseEquipment.fromString(json["equipment"]);
    final primaryMuscleGroups = (json["primary_muscle_groups"] as List<dynamic>)
        .map((muscleGroup) => MuscleGroup.fromString(muscleGroup))
        .toList();
    final secondaryMuscleGroups = (json["secondary_muscle_groups"] as List<dynamic>)
        .map((muscleGroup) => MuscleGroup.fromString(muscleGroup))
        .toList();

    return ExerciseDTO(
        name: name,
        description: description,
        metric: metric,
        modality: modality,
        equipment: equipment,
        primaryMuscleGroups: primaryMuscleGroups,
        secondaryMuscleGroups: secondaryMuscleGroups,
        movement: movement);
  }

  ExerciseDTO copyWith(
      {String? name,
      String? description,
      ExerciseMetric? metric,
      ExerciseModality? modality,
        ExerciseEquipment? equipment,
      List<MuscleGroup>? primaryMuscleGroups,
      List<MuscleGroup>? secondaryMuscleGroups,
      List<ExerciseDTO>? substituteExercises,
      CoreMovement? movement}) {
    return ExerciseDTO(
        name: name ?? this.name,
        description: description ?? this.description,
        metric: metric ?? this.metric,
        modality: modality ?? this.modality,
        equipment: equipment ?? this.equipment,
        primaryMuscleGroups: primaryMuscleGroups ?? this.primaryMuscleGroups,
        secondaryMuscleGroups: secondaryMuscleGroups ?? this.secondaryMuscleGroups,
        movement: movement ?? this.movement);
  }

  @override
  String toString() {
    return 'ExerciseDTO{name: $name, description: $description, metric: $metric, modality: $modality, equipment: $equipment, primaryMuscleGroups: $primaryMuscleGroups, secondaryMuscleGroups: $secondaryMuscleGroups, movement: $movement}';
  }
}

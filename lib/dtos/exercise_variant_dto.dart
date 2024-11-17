import 'package:tracker_app/enums/exercise/core_movements_enum.dart';
import 'package:tracker_app/enums/exercise/exercise_equipment_enum.dart';
import 'package:tracker_app/enums/exercise/exercise_metrics_enums.dart';
import 'package:tracker_app/enums/exercise/exercise_modality_enum.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';

import '../enums/exercise/exercise_movement_enum.dart';
import '../enums/exercise/exercise_position_enum.dart';
import '../enums/exercise/exercise_stance_enum.dart';

class ExerciseVariantDTO {
  final String id;
  final String name;
  final String description;
  final ExerciseMetric metric;
  final ExerciseModality mode;
  final ExercisePosition position;
  final ExerciseStance stance;
  final ExerciseEquipment equipment;
  final ExerciseMovement movement;
  final List<MuscleGroup> primaryMuscleGroups;
  final List<MuscleGroup> secondaryMuscleGroups;
  final CoreMovement coreMovement;

  ExerciseVariantDTO(
      {required this.id,
      required this.name,
      required this.description,
      required this.metric,
      required this.mode,
      required this.position,
      required this.stance,
      required this.equipment,
      required this.movement,
      required this.primaryMuscleGroups,
      required this.secondaryMuscleGroups,
      required this.coreMovement});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'primary_muscle_groups': secondaryMuscleGroups.map((muscleGroup) => muscleGroup.name).toList(),
      'secondary_muscle_groups': secondaryMuscleGroups.map((muscleGroup) => muscleGroup.name).toList(),
      'metric': metric.name,
      'mode': mode.name,
      'position': position.name,
      'stance': stance.name,
      'equipment': equipment.name,
      'movement': movement.name,
      'core_movement': coreMovement.name
    };
  }

  factory ExerciseVariantDTO.fromJson(Map<String, dynamic> json) {
    final id = json["id"];
    final name = json["name"];
    final description = json["description"];
    final metric = ExerciseMetric.fromString(json["metric"]);
    final mode = ExerciseModality.fromString(json["mode"]);
    final position = ExercisePosition.fromString(json["position"]);
    final stance = ExerciseStance.fromString(json["stance"]);
    final coreMovement = CoreMovement.fromString(json["core_movement"]);
    final movement = ExerciseMovement.fromString(json["movement"] ?? "");
    final equipment = ExerciseEquipment.fromString(json["equipment"]);
    final primaryMuscleGroups = (json["primary_muscle_groups"] as List<dynamic>)
        .map((muscleGroup) => MuscleGroup.fromString(muscleGroup))
        .toList();
    final secondaryMuscleGroups = (json["secondary_muscle_groups"] as List<dynamic>)
        .map((muscleGroup) => MuscleGroup.fromString(muscleGroup))
        .toList();

    return ExerciseVariantDTO(
        id: id,
        name: name,
        description: description,
        metric: metric,
        mode: mode,
        position: position,
        stance: stance,
        equipment: equipment,
        primaryMuscleGroups: primaryMuscleGroups,
        secondaryMuscleGroups: secondaryMuscleGroups,
        coreMovement: coreMovement,
        movement: movement);
  }

  ExerciseVariantDTO copyWith({
    String? id,
    String? name,
    String? description,
    ExerciseMetric? metric,
    ExerciseModality? mode,
    ExercisePosition? position,
    ExerciseStance? stance,
    ExerciseEquipment? equipment,
    List<MuscleGroup>? primaryMuscleGroups,
    List<MuscleGroup>? secondaryMuscleGroups,
    ExerciseMovement? movement,
    CoreMovement? coreMovement,
  }) {
    return ExerciseVariantDTO(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      metric: metric ?? this.metric,
      mode: mode ?? this.mode,
      position: position ?? this.position,
      stance: stance ?? this.stance,
      equipment: equipment ?? this.equipment,
      primaryMuscleGroups: primaryMuscleGroups ?? this.primaryMuscleGroups,
      secondaryMuscleGroups: secondaryMuscleGroups ?? this.secondaryMuscleGroups,
      coreMovement: coreMovement ?? this.coreMovement,
      movement: movement ?? this.movement,
    );
  }

  @override
  String toString() {
    return 'ExerciseVariantDTO{id: $id, name: $name, description: $description, metrics: ${metric.name}, modes: ${mode.name}, positions: ${position.name}, stances: ${stance.name}, equipment: ${equipment.name}, primaryMuscleGroups: ${primaryMuscleGroups.map((muscleGroup) => muscleGroup.name).join(", ")}, secondaryMuscleGroups: ${secondaryMuscleGroups.map((muscleGroup) => muscleGroup.name).join(", ")}, movement: ${movement.name}, coreMovement: ${coreMovement.name}';
  }
}

import 'package:tracker_app/dtos/exercise_variant_dto.dart';
import 'package:tracker_app/enums/exercise/core_movements_enum.dart';
import 'package:tracker_app/enums/exercise/exercise_equipment_enum.dart';
import 'package:tracker_app/enums/exercise/exercise_metrics_enums.dart';
import 'package:tracker_app/enums/exercise/exercise_modality_enum.dart';
import 'package:tracker_app/enums/exercise/exercise_movement_enum.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';

import '../enums/exercise/exercise_position_enum.dart';
import '../enums/exercise/exercise_stance_enum.dart';

class ExerciseDTO {
  final String id;
  final String name;
  final String description;
  final List<ExerciseMetric> metrics;
  final List<ExerciseModality> modes;
  final List<ExercisePosition> positions;
  final List<ExerciseStance> stances;
  final List<ExerciseEquipment> equipment;
  final List<ExerciseMovement> movements;
  final List<MuscleGroup> primaryMuscleGroups;
  final List<MuscleGroup> secondaryMuscleGroups;
  final CoreMovement coreMovement;

  ExerciseDTO(
      {required this.id,
        required this.name,
      required this.description,
      required this.metrics,
      required this.modes,
      required this.positions,
      required this.stances,
      required this.equipment,
      this.movements = const [],
      required this.primaryMuscleGroups,
      this.secondaryMuscleGroups = const [],
      required this.coreMovement});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'primary_muscle_groups': secondaryMuscleGroups.map((muscleGroup) => muscleGroup.name).toList(),
      'secondary_muscle_groups': secondaryMuscleGroups.map((muscleGroup) => muscleGroup.name).toList(),
      'metrics': metrics.map((metric) => metric.name).toList(),
      'modes': modes.map((mode) => mode.name).toList(),
      'positions': positions.map((position) => position.name).toList(),
      'stances': stances.map((stance) => stance.name).toList(),
      'equipment': equipment.map((equipment) => equipment.name).toList(),
      'movements': movements.map((movement) => movement.name).toList(),
      'core_movement': coreMovement.name
    };
  }

  factory ExerciseDTO.fromJson(Map<String, dynamic> json) {
    final id = json["id"];
    final name = json["name"];
    final description = json["description"];
    final metrics = (json["metrics"] as List<dynamic>).map((metric) => ExerciseMetric.fromString(metric)).toList();
    final coreMovement = CoreMovement.fromString(json["core_movement"]);
    final movements =
        (json["movements"] as List<dynamic>).map((movement) => ExerciseMovement.fromString(movement)).toList();
    final modes = (json["modes"] as List<dynamic>).map((mode) => ExerciseModality.fromString(mode)).toList();
    final positions =
        (json["positions"] as List<dynamic>).map((position) => ExercisePosition.fromString(position)).toList();
    final stances = (json["stances"] as List<dynamic>).map((stance) => ExerciseStance.fromString(stance)).toList();
    final equipment =
        (json["equipment"] as List<dynamic>).map((equipment) => ExerciseEquipment.fromString(equipment)).toList();
    final primaryMuscleGroups = (json["primary_muscle_groups"] as List<dynamic>)
        .map((muscleGroup) => MuscleGroup.fromString(muscleGroup))
        .toList();
    final secondaryMuscleGroups = (json["secondary_muscle_groups"] as List<dynamic>)
        .map((muscleGroup) => MuscleGroup.fromString(muscleGroup))
        .toList();

    return ExerciseDTO(
      id: id,
        name: name,
        description: description,
        metrics: metrics,
        modes: modes,
        positions: positions,
        stances: stances,
        movements: movements,
        equipment: equipment,
        primaryMuscleGroups: primaryMuscleGroups,
        secondaryMuscleGroups: secondaryMuscleGroups,
        coreMovement: coreMovement);
  }

  ExerciseDTO copyWith({
    String? id,
    String? name,
    String? description,
    List<ExerciseMetric>? metrics,
    List<ExerciseModality>? modes,
    List<ExercisePosition>? positions,
    List<ExerciseStance>? stances,
    List<ExerciseMovement>? movements,
    List<ExerciseEquipment>? equipment,
    List<MuscleGroup>? primaryMuscleGroups,
    List<MuscleGroup>? secondaryMuscleGroups,
    CoreMovement? coreMovement,
  }) {
    return ExerciseDTO(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      metrics: metrics ?? this.metrics,
      modes: modes ?? this.modes,
      positions: positions ?? this.positions,
      stances: stances ?? this.stances,
      movements: movements ?? this.movements,
      equipment: equipment ?? this.equipment,
      primaryMuscleGroups: primaryMuscleGroups ?? this.primaryMuscleGroups,
      secondaryMuscleGroups: secondaryMuscleGroups ?? this.secondaryMuscleGroups,
      coreMovement: coreMovement ?? this.coreMovement,
    );
  }

  @override
  String toString() {
    return 'ExerciseDTO{id: $id, name: $name, description: $description, metrics: $metrics, modes: $modes, positions: $positions, stances: $stances, equipment: $equipment, primaryMuscleGroups: $primaryMuscleGroups, secondaryMuscleGroups: $secondaryMuscleGroups, movement: $movements, coreMovement: ${coreMovement.name}}';
  }
}

extension ExerciseDTOExtension on ExerciseDTO {
  ExerciseVariantDTO defaultVariant() {
    return ExerciseVariantDTO(
        id: id,
        name: name,
        description: description,
        metric: metrics.first,
        mode: modes.first,
        position: positions.first,
        stance: stances.first,
        movement: movements.isNotEmpty ? movements.first : ExerciseMovement.none,
        equipment: equipment.first,
        primaryMuscleGroups: primaryMuscleGroups,
        secondaryMuscleGroups: secondaryMuscleGroups,
        coreMovement: coreMovement);
  }
}

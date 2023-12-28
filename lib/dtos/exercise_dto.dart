import 'dart:convert';

import '../enums/exercise_type_enums.dart';
import '../enums/muscle_group_enums.dart';

class ExerciseDto {
  final String id;
  final String name;
  final String notes;
  final MuscleGroup primaryMuscleGroup;
  final List<MuscleGroup> secondaryMuscleGroups;
  final ExerciseType type;

  ExerciseDto(
      {required this.id,
      required this.name,
      required this.notes,
      required this.primaryMuscleGroup,
      required this.secondaryMuscleGroups,
      required this.type});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'notes': notes,
      'primaryMuscleGroup': primaryMuscleGroup.name,
      'secondaryMuscleGroups': secondaryMuscleGroups.map((muscleGroup) => muscleGroup.name).toList(),
      'type': type.name
    };
  }

  factory ExerciseDto.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? "";
    final name = json["name"] ?? "";
    final notes = json["notes"] ?? "";
    final primaryMuscleGroup = json["primaryMuscleGroup"] ?? "";
    final secondaryMuscleGroupJsons = json["secondaryMuscleGroups"] as List<dynamic>;
    final secondaryMuscleGroups =
        secondaryMuscleGroupJsons.map((json) => MuscleGroup.fromString(jsonDecode(json))).toList();
    final typeJson = json["type"] ?? "";
    final type = ExerciseType.fromString(typeJson);

    return ExerciseDto(
        id: id,
        name: name,
        notes: notes,
        primaryMuscleGroup: MuscleGroup.fromString(primaryMuscleGroup),
        secondaryMuscleGroups: secondaryMuscleGroups,
        type: type);
  }

  ExerciseDto copyWith({
    String? id,
    String? name,
    String? notes,
    MuscleGroup? primaryMuscleGroup,
    List<MuscleGroup>? secondaryMuscleGroups,
    ExerciseType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExerciseDto(
        id: id ?? this.id,
        name: name ?? this.name,
        notes: notes ?? this.notes,
        primaryMuscleGroup: primaryMuscleGroup ?? this.primaryMuscleGroup,
        secondaryMuscleGroups: secondaryMuscleGroups ?? this.secondaryMuscleGroups,
        type: type ?? this.type);
  }

  @override
  String toString() {
    return 'ExerciseDto{id: $id, name: $name, notes: $notes, primaryMuscleGroup: $primaryMuscleGroup, secondaryMuscleGroups: $secondaryMuscleGroups, type: $type}';
  }
}

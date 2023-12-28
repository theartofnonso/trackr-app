import '../enums/exercise_type_enums.dart';
import '../enums/muscle_group_enums.dart';

class ExerciseDto {
  final String id;
  final String name;
  final String notes;
  final MuscleGroup primaryMuscleGroup;
  final List<MuscleGroup> secondaryMuscleGroups;
  final ExerciseType type;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExerciseDto({
    required this.id,
    required this.name,
    required this.notes,
    required this.primaryMuscleGroup,
    required this.secondaryMuscleGroups,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });

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
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ExerciseDto{id: $id, name: $name, notes: $notes, primaryMuscleGroup: $primaryMuscleGroup, secondaryMuscleGroups: $secondaryMuscleGroups, type: $type, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}

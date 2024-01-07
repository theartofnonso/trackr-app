import '../enums/exercise_type_enums.dart';
import '../enums/muscle_group_enums.dart';

class ExerciseDto {
  final String id;
  final String name;
  final MuscleGroup primaryMuscleGroup;
  final ExerciseType type;

  ExerciseDto({required this.id, required this.name, required this.primaryMuscleGroup, required this.type});

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'primaryMuscleGroup': primaryMuscleGroup.name, 'type': type.id};
  }

  factory ExerciseDto.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? "";
    final name = json["name"] ?? "";
    final primaryMuscleGroup = json["primaryMuscleGroup"] ?? "";
    final typeJson = json["type"] ?? "";
    final type = ExerciseType.fromString(typeJson);

    return ExerciseDto(id: id, name: name, primaryMuscleGroup: MuscleGroup.fromString(primaryMuscleGroup), type: type);
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
        primaryMuscleGroup: primaryMuscleGroup ?? this.primaryMuscleGroup,
        type: type ?? this.type);
  }

  @override
  String toString() {
    return 'ExerciseDto{id: $id, name: $name, primaryMuscleGroup: $primaryMuscleGroup, type: $type}';
  }
}

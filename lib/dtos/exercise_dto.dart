import '../enums/exercise_type_enums.dart';
import '../enums/muscle_group_enums.dart';

class ExerciseDto {
  final String id;
  final String name;
  final MuscleGroup primaryMuscleGroup;
  final ExerciseType type;
  final bool owner;

  ExerciseDto({required this.id, required this.name, required this.primaryMuscleGroup, required this.type, required this.owner});

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'primaryMuscleGroup': primaryMuscleGroup.name, 'type': type.id, 'owner': owner};
  }

  factory ExerciseDto.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? "";
    final name = json["name"] ?? "";
    final primaryMuscleGroup = json["primaryMuscleGroup"] ?? "";
    final typeJson = json["type"] ?? "";
    final type = ExerciseType.fromString(typeJson);
    final owner = json["owner"] ?? false;

    return ExerciseDto(id: id, name: name, primaryMuscleGroup: MuscleGroup.fromString(primaryMuscleGroup), type: type, owner: owner);
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
    bool? owner,
  }) {
    return ExerciseDto(
        id: id ?? this.id,
        name: name ?? this.name,
        primaryMuscleGroup: primaryMuscleGroup ?? this.primaryMuscleGroup,
        type: type ?? this.type, owner: owner ?? this.owner);
  }

  @override
  String toString() {
    return 'ExerciseDto{id: $id, name: $name, primaryMuscleGroup: $primaryMuscleGroup, type: $type, owner: $owner}';
  }
}

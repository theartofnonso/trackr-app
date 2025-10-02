import '../../enums/exercise_type_enums.dart';
import '../../enums/muscle_group_enums.dart';

class ExerciseDto {
  final String id;
  final String name;
  final MuscleGroup primaryMuscleGroup;
  final List<MuscleGroup> secondaryMuscleGroups;
  final ExerciseType type;

  ExerciseDto({
    required this.id,
    required this.name,
    required this.primaryMuscleGroup,
    required this.secondaryMuscleGroups,
    required this.type,
  });

  Map<String, Object> toJson() {
    return {
      'id': id,
      'name': name,
      'primaryMuscleGroup': primaryMuscleGroup.name,
      'secondaryMuscleGroups':
          secondaryMuscleGroups.map((muscleGroup) => muscleGroup.name).toList(),
      'type': type.id,
    };
  }

  // Removed Amplify model conversion

  factory ExerciseDto.fromJson(Map<String, dynamic> json,
      {String? exerciseId}) {
    final id = exerciseId ?? json["id"] ?? "";
    final name = json["name"] ?? "";
    final primaryMuscleGroupString = json["primaryMuscleGroup"] ?? "";
    final primaryMuscleGroup = MuscleGroup.fromString(primaryMuscleGroupString);
    final secondaryMuscleGroupString =
        (json["secondaryMuscleGroups"] as List<dynamic>?) ?? [];
    final secondaryMuscleGroups = secondaryMuscleGroupString
        .map((muscleGroup) => MuscleGroup.fromString(muscleGroup))
        .toList();
    final typeJson = json["type"] ?? "";
    final type = ExerciseType.fromString(typeJson);

    return ExerciseDto(
        id: id,
        name: name,
        primaryMuscleGroup: primaryMuscleGroup,
        secondaryMuscleGroups: secondaryMuscleGroups,
        type: type);
  }

  ExerciseDto copyWith({
    String? id,
    String? name,
    MuscleGroup? primaryMuscleGroup,
    List<MuscleGroup>? secondaryMuscleGroups,
    ExerciseType? type,
  }) {
    return ExerciseDto(
      id: id ?? this.id,
      name: name ?? this.name,
      primaryMuscleGroup: primaryMuscleGroup ?? this.primaryMuscleGroup,

      // Create a new list for secondaryMuscleGroups to avoid referencing the original.
      secondaryMuscleGroups: secondaryMuscleGroups != null
          ? List<MuscleGroup>.from(secondaryMuscleGroups)
          : List<MuscleGroup>.from(this.secondaryMuscleGroups),

      type: type ?? this.type,
    );
  }

  @override
  String toString() {
    return 'ExerciseDto{id: $id, name: $name, primaryMuscleGroup: ${primaryMuscleGroup.name}, secondaryMuscleGroups: $secondaryMuscleGroups, type: $type}';
  }

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) {
    return other is ExerciseDto && other.id == id;
  }
}

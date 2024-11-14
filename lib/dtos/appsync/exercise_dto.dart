import 'dart:convert';

import 'package:tracker_app/dtos/appsync/routine_log_dto.dart';
import 'package:tracker_app/dtos/appsync/routine_template_dto.dart';
import 'package:tracker_app/enums/training_position_enum.dart';

import '../../enums/exercise_type_enums.dart';
import '../../enums/muscle_group_enums.dart';
import '../../models/Exercise.dart';

class ExerciseDto {
  final String id;
  final String name;
  final MuscleGroup primaryMuscleGroup;
  final List<MuscleGroup> secondaryMuscleGroups;
  final Uri? video;
  final String? description;
  final Uri? creditSource;
  final String? credit;
  final ExerciseType type;
  final String owner;

  ExerciseDto(
      {required this.id,
      required this.name,
      required this.primaryMuscleGroup,
      required this.secondaryMuscleGroups,
      required this.type,
      this.description,
      this.video,
      this.creditSource,
      this.credit,
      required this.owner});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'primaryMuscleGroup': primaryMuscleGroup.name,
      'secondaryMuscleGroups': secondaryMuscleGroups.map((muscleGroup) => jsonEncode(muscleGroup.name)).toList(),
      'type': type.id,
      'owner': owner,
      'description': description,
      'video': video?.toString(),
      'creditSource': creditSource?.toString(),
      'credit': credit
    };
  }

  /// Only use this when loading user's custom exercise from DB
  factory ExerciseDto.toDto(Exercise exercise) {
    return ExerciseDto.fromExercise(exercise: exercise);
  }

  /// Only use this when loading user's custom exercise from DB
  factory ExerciseDto.fromExercise({required Exercise exercise}) {
    final json = jsonDecode(exercise.data) as Map<String, dynamic>;
    final exerciseDto = ExerciseDto.fromJson(json);
    return ExerciseDto(
        id: exercise.id,
        name: exerciseDto.name,
        primaryMuscleGroup: exerciseDto.primaryMuscleGroup,
        secondaryMuscleGroups: exerciseDto.secondaryMuscleGroups,
        type: exerciseDto.type,
        owner: exercise.owner ?? "");
  }

  /// No need to load full data because [RoutineTemplateDto] and [RoutineLogDto] are always synced with the [ExerciseDto]
  /// Syncing happens when [ExerciseDto] is loaded due to CRUD operations or when
  factory ExerciseDto.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? "";
    final name = json["name"] ?? "";
    final primaryMuscleGroupString = json["primaryMuscleGroup"] ?? "";
    final primaryMuscleGroup = MuscleGroup.fromString(primaryMuscleGroupString);
    final typeJson = json["type"] ?? "";
    final type = ExerciseType.fromString(typeJson);
    return ExerciseDto(
        id: id,
        name: name,
        primaryMuscleGroup: primaryMuscleGroup,
        secondaryMuscleGroups: [],
        type: type,
        owner: "");
  }

  ExerciseDto copyWith({
    String? id,
    String? name,
    MuscleGroup? primaryMuscleGroup,
    List<MuscleGroup>? secondaryMuscleGroups,
    ExerciseType? type,
    TrainingPosition? trainingPosition,
    String? owner,
    String? description,
  }) {
    return ExerciseDto(
        id: id ?? this.id,
        name: name ?? this.name,
        primaryMuscleGroup: primaryMuscleGroup ?? this.primaryMuscleGroup,
        secondaryMuscleGroups: secondaryMuscleGroups ?? this.secondaryMuscleGroups,
        type: type ?? this.type,
        owner: owner ?? this.owner,
        description: description ?? this.description);
  }

  @override
  String toString() {
    return 'ExerciseDto{id: $id, name: $name, primaryMuscleGroup: ${primaryMuscleGroup.name}, secondaryMuscleGroups: $secondaryMuscleGroups video: $video, description: $description, creditSource: $creditSource, credit: $credit, type: $type, owner: $owner}';
  }

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) {
    return other is ExerciseDto && other.id == id;
  }
}

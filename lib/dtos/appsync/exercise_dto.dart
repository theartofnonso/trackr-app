import 'package:tracker_app/enums/training_position_enum.dart';

import '../../enums/exercise_type_enums.dart';
import '../../enums/muscle_group_enums.dart';

class ExerciseDto {
  final String id;
  final String name;
  final MuscleGroup primaryMuscleGroup;
  final List<MuscleGroup> secondaryMuscleGroups;
  final TrainingPosition trainingPosition;
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
      required this.trainingPosition,
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
      'type': type.id,
      'owner': owner,
      'description': description,
      'video': video?.toString(),
      'creditSource': creditSource?.toString(),
      'credit': credit
    };
  }

  factory ExerciseDto.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? "";
    final name = json["name"] ?? "";
    final primaryMuscleGroupString = json["primaryMuscleGroup"] ?? "";
    final primaryMuscleGroup = MuscleGroup.fromString(primaryMuscleGroupString);
    final secondaryMuscleGroupString = (json["secondaryMuscleGroups"] as List<dynamic>?) ?? [];
    final secondaryMuscleGroups =
        secondaryMuscleGroupString.map((muscleGroup) => MuscleGroup.fromString(muscleGroup)).toList();
    final typeJson = json["type"] ?? "";
    final type = ExerciseType.fromString(typeJson);
    final trainingPositionString = json["trainingPosition"] ?? "";
    final trainingPosition = TrainingPosition.fromString(trainingPositionString);
    final owner = json["owner"] ?? false;
    final video = json["video"];
    final description = json["description"] ?? "";
    final videoUri = video != null ? Uri.parse(video) : null;
    final creditSource = json["creditSource"];
    final creditSourceUri = creditSource != null ? Uri.parse(creditSource) : null;
    final credit = json["credit"] ?? "";
    return ExerciseDto(
        id: id,
        name: name,
        primaryMuscleGroup: primaryMuscleGroup,
        secondaryMuscleGroups: secondaryMuscleGroups,
        type: type,
        video: videoUri,
        description: description,
        trainingPosition: trainingPosition,
        owner: owner.toString(),
        creditSource: creditSourceUri,
        credit: credit);
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
        trainingPosition: trainingPosition ?? this.trainingPosition,
        type: type ?? this.type,
        owner: owner ?? this.owner,
        description: description ?? this.description);
  }

  @override
  String toString() {
    return 'ExerciseDto{id: $id, name: $name, primaryMuscleGroup: $primaryMuscleGroup, secondaryMuscleGroups: $secondaryMuscleGroups video: $video, description: $description, trainingPosition: $trainingPosition, creditSource: $creditSource, credit: $credit, type: $type, owner: $owner}';
  }

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) {
    return other is ExerciseDto &&
        other.id == id;
  }

}

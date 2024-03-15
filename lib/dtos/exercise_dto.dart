import '../enums/exercise_type_enums.dart';
import '../enums/muscle_group_enums.dart';

class ExerciseDto {
  final String id;
  final String name;
  final MuscleGroup primaryMuscleGroup;
  final Uri? video;
  final Uri? creditSource;
  final String? credit;
  final ExerciseType type;
  final bool owner;

  ExerciseDto(
      {required this.id,
      required this.name,
      required this.primaryMuscleGroup,
      required this.type,
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
      'video': video?.toString(),
      'creditSource': creditSource?.toString(),
      'credit': credit
    };
  }

  factory ExerciseDto.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? "";
    final name = json["name"] ?? "";
    final primaryMuscleGroupJson = json["primaryMuscleGroup"] ?? "";
    final primaryMuscleGroup = MuscleGroup.fromString(primaryMuscleGroupJson);
    final typeJson = json["type"] ?? "";
    final type = ExerciseType.fromString(typeJson);
    final owner = json["owner"] ?? false;
    final video = json["video"];
    final videoUri = video != null ? Uri.parse(video) : null;
    final creditSource = json["creditSource"];
    final creditSourceUri = creditSource != null ? Uri.parse(creditSource) : null;
    final credit = json["credit"] ?? "";

    return ExerciseDto(
        id: id,
        name: name,
        primaryMuscleGroup: primaryMuscleGroup,
        type: type,
        video: videoUri,
        owner: owner,
        creditSource: creditSourceUri,
        credit: credit);
  }

  ExerciseDto copyWith({
    String? id,
    String? name,
    MuscleGroup? primaryMuscleGroup,
    ExerciseType? type,
    bool? owner,
  }) {
    return ExerciseDto(
        id: id ?? this.id,
        name: name ?? this.name,
        primaryMuscleGroup: primaryMuscleGroup ?? this.primaryMuscleGroup,
        type: type ?? this.type,
        owner: owner ?? this.owner);
  }

  @override
  String toString() {
    return 'ExerciseDto{id: $id, name: $name, primaryMuscleGroup: $primaryMuscleGroup, video: $video, creditSource: $creditSource, credit: $credit, type: $type, owner: $owner}';
  }
}

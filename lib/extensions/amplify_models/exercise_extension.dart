import 'package:tracker_app/dtos/appsync/exercise_dto.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import '../../enums/exercise_type_enums.dart';

extension ExerciseExtensionLocal on Object {
  static ExerciseDto dtoLocal(dynamic json) {
    final id = json["id"];
    final name = json["name"];
    final primaryMuscleGroupString = json["primaryMuscleGroup"] ?? "";
    final primaryMuscleGroup = MuscleGroup.fromString(primaryMuscleGroupString);
    final secondaryMuscleGroupJson =
        json["secondaryMuscleGroups"] as List<dynamic>;
    final secondaryMuscleGroups = secondaryMuscleGroupJson
        .map((muscleGroup) => MuscleGroup.fromString(muscleGroup))
        .toList();
    final typeString = json["type"];
    final video = json["video"];
    final videoUri = video != null ? Uri.parse(video) : null;
    final description = json["description"];
    final creditSource = json["creditSource"];
    final creditSourceUri = video != null ? Uri.parse(creditSource) : null;
    final credit = json["credit"];
    return ExerciseDto(
        id: id,
        name: name,
        primaryMuscleGroup: primaryMuscleGroup,
        secondaryMuscleGroups: secondaryMuscleGroups,
        type: ExerciseType.fromString(typeString),
        video: videoUri,
        description: description,
        creditSource: creditSourceUri,
        credit: credit,
        owner: "");
  }
}

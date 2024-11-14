import 'dart:convert';

import 'package:tracker_app/dtos/appsync/exercise_dto.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/models/ModelProvider.dart';
import 'package:tracker_app/shared_prefs.dart';

import '../../enums/exercise_type_enums.dart';

extension ExerciseExtension on Exercise {
  static ExerciseDto dtoFromLocal(dynamic json) {
    final id = json["id"];
    final name = json["name"];
    final primaryMuscleGroup = MuscleGroup.fromString(json["primaryMuscleGroup"] ?? "");
    final secondaryMuscleGroups = (json["secondaryMuscleGroups"] as List<dynamic>)
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

  ExerciseDto dtoFromCustom() {
    final json = jsonDecode(data);
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
        owner: owner ?? SharedPrefs().userId);
  }
}

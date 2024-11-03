import 'dart:convert';

import 'package:tracker_app/enums/challenge_type_enums.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/models/ModelProvider.dart';

import '../../dtos/appsync/challenge_log_dto.dart';
import '../../dtos/appsync/exercise_dto.dart';

extension ChallengeLogExtension on ChallengeLog {
  ChallengeLogDto dto() {
    final json = jsonDecode(data);
    final templateId = json["templateId"] ?? "";
    final name = json["name"] ?? "";
    final caption = json["caption"] ?? "";
    final description = json["description"] ?? "";
    final rule = json["rule"] ?? "";
    final progress = json["progress"] ?? 0;
    final startDate = DateTime.parse(json["startDate"]);
    final endDate = json["endDate"] != null ? DateTime.parse(json["endDate"]) : null;
    final isCompleted = json["isCompleted"] ?? false;
    final muscleGroupString = json["muscleGroup"] ?? "";
    final muscleGroup = MuscleGroup.fromString(muscleGroupString);
    final exerciseString = json["exercise"];
    final exercise = exerciseString != null ? ExerciseDto.fromJson(exerciseString) : null;
    final weight = json["weight"] ?? 0;
    final typeString = json["type"] ?? "";
    final type = ChallengeType.fromString(typeString);

    return ChallengeLogDto(
        id: id,
        templateId: templateId,
        name: name,
        caption: caption,
        description: description,
        rule: rule,
        progress: progress,
        startDate: startDate,
        endDate: endDate,
        isCompleted: isCompleted,
        type: type,
        muscleGroup: muscleGroup,
        weight: weight,
        exercise: exercise);
  }
}

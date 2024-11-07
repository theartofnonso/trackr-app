import 'dart:convert';

import 'package:tracker_app/dtos/appsync/exercise_dto.dart';
import 'package:tracker_app/models/ModelProvider.dart';
import 'package:tracker_app/utils/exercise_logs_utils.dart';

import '../../dtos/exercise_log_dto.dart';
import '../../dtos/appsync/routine_log_dto.dart';

extension RoutineLogExtension on RoutineLog {

  RoutineLogDto dto({required List<ExerciseDto> exercises}) {
    final json = jsonDecode(data);
    final templateId = json["templateId"] ?? "";
    final name = json["name"] ?? "";
    final notes = json["notes"] ?? "";
    final summary = json["summary"];
    final startTime = DateTime.parse(json["startTime"]);
    final endTime = DateTime.parse(json["endTime"]);
    final exerciseLogJsons = json["exercises"] as List<dynamic>;
    final exerciseLogs = exerciseLogJsons.map((json) => ExerciseLogDto.fromJson(routineLogId: id, createdAt: createdAt.getDateTimeInUtc(), json: jsonDecode(json))).toList();
    final updatedExerciseLogs = syncExercisesFromLibrary(exerciseLogs: exerciseLogs, exercises: exercises);
    return RoutineLogDto(
      id: id,
      templateId: templateId,
      name: name,
      exerciseLogs: updatedExerciseLogs,
      notes: notes,
      summary: summary,
      startTime: startTime,
      endTime: endTime,
      owner: owner ?? "",
      createdAt: createdAt.getDateTimeInUtc(),
      updatedAt: updatedAt.getDateTimeInUtc(),
    );
  }

}
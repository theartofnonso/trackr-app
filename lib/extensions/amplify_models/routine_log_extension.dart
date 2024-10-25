import 'dart:convert';

import 'package:tracker_app/models/ModelProvider.dart';

import '../../dtos/exercise_log_dto.dart';
import '../../dtos/routine_log_dto.dart';

extension RoutineLogExtension on RoutineLog {

  RoutineLogDto dto() {
    final json = jsonDecode(data);
    final templateId = json["templateId"] ?? "";
    final name = json["name"] ?? "";
    final notes = json["notes"] ?? "";
    final summary = json["summary"];
    final startTime = DateTime.parse(json["startTime"]);
    final endTime = DateTime.parse(json["endTime"]);
    final exerciseLogJsons = json["exercises"] as List<dynamic>;
    final exerciseLogs = exerciseLogJsons.map((json) => ExerciseLogDto.fromJson(routineLogId: id, createdAt: createdAt.getDateTimeInUtc(), json: jsonDecode(json))).toList();
    return RoutineLogDto(
      id: id,
      templateId: templateId,
      name: name,
      exerciseLogs: exerciseLogs,
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
import 'dart:convert';

import 'package:tracker_app/models/ModelProvider.dart';

import '../dtos/exercise_log_dto.dart';
import '../dtos/routine_log_dto.dart';

extension RoutineLogExtension on RoutineLog {

  RoutineLogDto dto() {
    final dataJson = jsonDecode(data);
    final templateId = dataJson["templateId"] ?? "";
    final name = dataJson["name"] ?? "";
    final notes = dataJson["notes"] ?? "";
    final startTime = DateTime.parse(dataJson["startTime"]);
    final endTime = DateTime.parse(dataJson["endTime"]);
    final exerciseLogJsons = dataJson["exercises"] as List<dynamic>;
    final exerciseLogs = exerciseLogJsons.map((json) => ExerciseLogDto.fromJson(json: jsonDecode(json))).toList();
    return RoutineLogDto(
      id: id,
      templateId: templateId,
      name: name,
      exerciseLogs: exerciseLogs,
      notes: notes,
      startTime: startTime,
      endTime: endTime,
      createdAt: createdAt.getDateTimeInUtc(),
      updatedAt: updatedAt.getDateTimeInUtc(),
    );
  }

}
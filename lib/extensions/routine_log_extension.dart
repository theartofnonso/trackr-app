import 'dart:convert';

import 'package:tracker_app/models/ModelProvider.dart';

import '../dtos/exercise_log_dto.dart';
import '../dtos/routine_log_dto.dart';

extension RoutineLogExtension on RoutineLog {

  RoutineLogDto dto() {
    final dataJson = jsonDecode(data);
    final templateId = dataJson["templateId"];
    final name = dataJson["name"];
    final notes = dataJson["notes"];
    final startTime = dataJson["startTime"] as DateTime;
    final endTime = dataJson["endTime"] as DateTime;
    final exerciseLogs = dataJson["exercises"].map((exerciseLog) => ExerciseLogDto.fromJson(json: exerciseLog)).toList();

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
import 'dart:convert';

import 'package:tracker_app/models/ModelProvider.dart';

import '../dtos/exercise_log_dto.dart';
import '../dtos/routine_template_dto.dart';
import '../enums/week_days_enum.dart';

extension RoutineTemplateExtension on RoutineTemplate {

  RoutineTemplateDto dto() {
    final dataJson = jsonDecode(data);

    final name = dataJson["name"] ?? "";
    final notes = dataJson["notes"] ?? "";
    final exerciseLogJsons = dataJson["exercises"] as List<dynamic>;
    final exercises = exerciseLogJsons.map((json) => ExerciseLogDto.fromJson(json: jsonDecode(json))).toList();
    final days = dataJson["days"] as List<dynamic>? ?? [];
    final daysOfWeek = days.map((day) => DayOfWeek.fromDateTime(day)).toList();

    return RoutineTemplateDto(
      id: id,
      name: name,
      exercises: exercises,
      days: daysOfWeek,
      notes: notes,
      createdAt: createdAt.getDateTimeInUtc(),
      updatedAt: updatedAt.getDateTimeInUtc(),
    );
  }
}
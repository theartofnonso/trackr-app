import 'dart:convert';

import 'package:tracker_app/enums/routine_schedule_type_enums.dart';
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
    final scheduleIntervals = dataJson["scheduleIntervals"] ?? 0;
    final scheduledDateString = dataJson["scheduledDate"];
    final scheduledDate = scheduledDateString != null ? DateTime.parse(scheduledDateString) : null;
    final scheduleTypeString = dataJson["scheduleType"];
    final scheduleType = scheduleTypeString != null ? RoutineScheduleType.fromString(scheduleTypeString) : RoutineScheduleType.days;
    final scheduledDays = dataJson["days"] as List<dynamic>? ?? [];
    final daysOfWeek = scheduledDays.map((day) => DayOfWeek.fromWeekDay(day)).toList();

    return RoutineTemplateDto(
      id: id,
      name: name,
      exerciseTemplates: exercises,
      scheduledDays: daysOfWeek,
      notes: notes,
      scheduleIntervals: scheduleIntervals,
      scheduledDate: scheduledDate,
      scheduleType: scheduleType,
      createdAt: createdAt.getDateTimeInUtc(),
      updatedAt: updatedAt.getDateTimeInUtc(),
    );
  }
}

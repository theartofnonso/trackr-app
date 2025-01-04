import 'dart:convert';

import 'package:tracker_app/dtos/appsync/routine_log_dto.dart';
import 'package:tracker_app/enums/routine_schedule_type_enums.dart';

import '../../enums/week_days_enum.dart';
import '../../models/RoutineTemplate.dart';
import '../exercise_log_dto.dart';

class RoutineTemplateDto {
  final String id;
  final String name;
  final String notes;
  final RoutineScheduleType scheduleType;
  final List<ExerciseLogDto> exerciseTemplates;
  final List<DayOfWeek> scheduledDays;
  final DateTime? scheduledDate;
  final String owner;
  final String workoutVideoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  RoutineTemplateDto(
      {required this.id,
      required this.name,
      required this.exerciseTemplates,
      this.scheduledDays = const [],
      required this.notes,
      required this.createdAt,
      required this.updatedAt,
      this.scheduledDate,
      required this.owner,
      this.workoutVideoUrl = "",
      this.scheduleType = RoutineScheduleType.none});

  Map<String, Object> toJson() {
    return {
      "id": id,
      'name': name,
      'notes': notes,
      'exercises': exerciseTemplates.map((exercise) => exercise.toJson()).toList(),
      'days': scheduledDays.map((dayOfWeek) => dayOfWeek.day).toList(),
      'workoutVideoUrl': workoutVideoUrl,
      "scheduledDate": scheduledDate?.toIso8601String() ?? "",
      "scheduleType": scheduleType.name,
    };
  }

  factory RoutineTemplateDto.toDto(RoutineTemplate template) {
    return RoutineTemplateDto.fromTemplate(template: template);
  }

  factory RoutineTemplateDto.fromTemplate({required RoutineTemplate template}) {
    final json = jsonDecode(template.data);
    final name = json["name"] ?? "";
    final notes = json["notes"] ?? "";
    final exerciseTemplatesInJson = json["exercises"] as List<dynamic>;
    final workoutVideoUrl = (json["workoutVideoUrl"] as String?) ?? "";
    List<ExerciseLogDto> exerciseTemplates = [];
    if (exerciseTemplatesInJson.isNotEmpty && exerciseTemplatesInJson.first is String) {
      exerciseTemplates = exerciseTemplatesInJson
          .map((json) => ExerciseLogDto.fromJson(
              routineLogId: template.id, json: jsonDecode(json), createdAt: template.createdAt.getDateTimeInUtc()))
          .toList();
    } else {
      exerciseTemplates = exerciseTemplatesInJson
          .map((json) => ExerciseLogDto.fromJson(
              routineLogId: template.id, createdAt: template.createdAt.getDateTimeInUtc(), json: json))
          .toList();
    }
    final scheduledDateString = (json["scheduledDate"] as String?) ?? "";
    final scheduledDate = scheduledDateString.isNotEmpty ? DateTime.parse(scheduledDateString) : null;
    final scheduleTypeString = json["scheduleType"];
    final scheduleType =
        scheduleTypeString != null ? RoutineScheduleType.fromJson(scheduleTypeString) : RoutineScheduleType.days;
    final scheduledDays = json["days"] as List<dynamic>? ?? [];
    final daysOfWeek = scheduledDays.map((day) => DayOfWeek.fromWeekDay(day)).toList();

    return RoutineTemplateDto(
      id: template.id,
      name: name,
      exerciseTemplates: exerciseTemplates,
      scheduledDays: daysOfWeek,
      notes: notes,
      scheduledDate: scheduledDate,
      scheduleType: scheduleType,
      owner: template.owner ?? "",
      workoutVideoUrl: workoutVideoUrl,
      createdAt: template.createdAt.getDateTimeInUtc(),
      updatedAt: template.updatedAt.getDateTimeInUtc(),
    );
  }

  RoutineLogDto toLog() {
    return RoutineLogDto(
        id: "",
        templateId: id,
        name: name,
        exerciseLogs: List.from(exerciseTemplates),
        notes: notes,
        owner: owner,
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now());
  }

  RoutineTemplateDto copyWith({
    String? id,
    String? name,
    String? notes,
    List<ExerciseLogDto>? exerciseTemplates,
    List<DayOfWeek>? scheduledDays,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? scheduledDate,
    String? owner,
    String? workoutVideoUrl,
    RoutineScheduleType? scheduleType,
  }) {
    return RoutineTemplateDto(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      workoutVideoUrl: workoutVideoUrl ?? this.workoutVideoUrl,
      // Deep copy each ExerciseLogDto.
      exerciseTemplates: exerciseTemplates != null
          ? exerciseTemplates.map((e) => e.copyWith()).toList()
          : this.exerciseTemplates.map((e) => e.copyWith()).toList(),

      // Create a new List<DayOfWeek> to avoid referencing the original list.
      scheduledDays:
          scheduledDays != null ? List<DayOfWeek>.from(scheduledDays) : List<DayOfWeek>.from(this.scheduledDays),

      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduleType: scheduleType ?? this.scheduleType,
      owner: owner ?? this.owner,
    );
  }

  @override
  String toString() {
    return 'RoutineTemplateDto{id: $id, name: $name, notes: $notes, workoutVideoUrl: $workoutVideoUrl, exerciseTemplates: $exerciseTemplates, days: $scheduledDays, schedule: $scheduledDate, scheduleType: $scheduleType, owner: $owner, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}

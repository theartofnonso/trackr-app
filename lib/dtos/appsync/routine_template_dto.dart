import 'package:tracker_app/dtos/appsync/routine_log_dto.dart';
import 'package:tracker_app/enums/routine_schedule_type_enums.dart';

import '../../enums/week_days_enum.dart';
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
      this.scheduleType = RoutineScheduleType.none});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'notes': notes,
      'exercises': exerciseTemplates.map((exercise) => exercise.toJson()).toList(),
      'days': scheduledDays.map((dayOfWeek) => dayOfWeek.day).toList(),
      "scheduledDate": scheduledDate?.toIso8601String(),
      "scheduleType": scheduleType.name,
    };
  }

  RoutineLogDto log() {
    return RoutineLogDto(
        id: "",
        templateId: id,
        name: name,
        exerciseLogs: exerciseTemplates,
        notes: notes,
        owner: owner,
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now());
  }

  RoutineTemplateDto copyWith(
      {String? id,
      String? name,
      String? notes,
      DateTime? startTime,
      DateTime? endTime,
      List<ExerciseLogDto>? exerciseTemplates,
      List<DayOfWeek>? scheduledDays,
      DateTime? createdAt,
      DateTime? updatedAt,
      DateTime? scheduledDate,
      String? owner,
      RoutineScheduleType? scheduleType}) {
    return RoutineTemplateDto(
        id: id ?? this.id,
        name: name ?? this.name,
        notes: notes ?? this.notes,
        exerciseTemplates: exerciseTemplates ?? this.exerciseTemplates,
        scheduledDays: scheduledDays ?? this.scheduledDays,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        scheduledDate: scheduledDate ?? this.scheduledDate,
        scheduleType: scheduleType ?? this.scheduleType,
        owner: owner ?? this.owner);
  }

  @override
  String toString() {
    return 'RoutineTemplateDto{id: $id, name: $name, notes: $notes, exerciseTemplates: $exerciseTemplates, days: $scheduledDays, schedule: $scheduledDate, scheduleType: $scheduleType, owner: $owner, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}

import 'package:tracker_app/dtos/routine_log_dto.dart';

import '../enums/week_days_enum.dart';
import 'exercise_log_dto.dart';

class RoutineTemplateDto {
  final String id;
  final String name;
  final String notes;
  final List<ExerciseLogDto> exerciseTemplates;
  final List<DayOfWeek> days;
  final DateTime createdAt;
  final DateTime updatedAt;

  RoutineTemplateDto({
    required this.id,
    required this.name,
    required this.exerciseTemplates,
    this.days = const [],
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'notes': notes,
      'exercises': exerciseTemplates.map((exercise) => exercise.toJson()).toList(),
      'days': days.map((dayOfWeek) => dayOfWeek.day).toList(),
    };
  }

  RoutineLogDto log() {
    return RoutineLogDto(
        id: "",
        templateId: id,
        name: name,
        exerciseLogs: exerciseTemplates,
        notes: notes,
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now());
  }

  RoutineTemplateDto copyWith({
    String? id,
    String? name,
    String? notes,
    DateTime? startTime,
    DateTime? endTime,
    List<ExerciseLogDto>? exerciseTemplates,
    List<DayOfWeek>? days,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoutineTemplateDto(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      exerciseTemplates: exerciseTemplates ?? this.exerciseTemplates,
      days: days ?? this.days,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'RoutineTemplateDto{id: $id, name: $name, notes: $notes, exerciseTemplates: $exerciseTemplates, days: $days, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}

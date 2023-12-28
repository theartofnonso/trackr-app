import 'package:tracker_app/dtos/routine_log_dto.dart';

import 'exercise_log_dto.dart';

class RoutineTemplateDto {
  final String id;
  final String name;
  final String notes;
  final List<ExerciseLogDto> exercises;
  final DateTime createdAt;
  final DateTime updatedAt;

  RoutineTemplateDto({
    required this.id,
    required this.name,
    required this.exercises,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  RoutineLogDto log() {
    return RoutineLogDto(
        id: "",
        templateId: id,
        name: name,
        exerciseLogs: exercises,
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
    List<ExerciseLogDto>? exercises,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoutineTemplateDto(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      exercises: exercises ?? this.exercises,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

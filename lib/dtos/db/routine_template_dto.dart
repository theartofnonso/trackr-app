import 'package:tracker_app/dtos/db/routine_log_dto.dart';

import '../exercise_log_dto.dart';

class RoutineTemplateDto {
  final String id;
  final String name;
  final String notes;
  final List<ExerciseLogDto> exerciseTemplates;
  final DateTime createdAt;
  final DateTime updatedAt;

  RoutineTemplateDto({
    required this.id,
    required this.name,
    required this.exerciseTemplates,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, Object> toJson() {
    return {
      "id": id,
      'name': name,
      'notes': notes,
      'exercises':
          exerciseTemplates.map((exercise) => exercise.toJson()).toList(),
    };
  }

  RoutineLogDto toLog() {
    return RoutineLogDto(
        id: "",
        templateId: id,
        name: name,
        exerciseLogs: List.from(exerciseTemplates),
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
    List<ExerciseLogDto>? exerciseTemplates,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoutineTemplateDto(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      // Deep copy each ExerciseLogDto.
      exerciseTemplates: exerciseTemplates != null
          ? exerciseTemplates.map((e) => e.copyWith()).toList()
          : this.exerciseTemplates.map((e) => e.copyWith()).toList(),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'RoutineTemplateDto{id: $id, name: $name, notes: $notes, exerciseTemplates: $exerciseTemplates, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}

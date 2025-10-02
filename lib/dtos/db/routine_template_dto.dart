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

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      'name': name,
      'notes': notes,
      'exercises':
          exerciseTemplates.map((exercise) => exercise.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory RoutineTemplateDto.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? '';
    final name = json['name'] ?? '';
    final notes = json['notes'] ?? '';
    final exercisesJson = json['exercises'] as List<dynamic>? ?? [];
    final exerciseTemplates = exercisesJson
        .map((exerciseJson) => ExerciseLogDto.fromJson(json: exerciseJson))
        .toList();
    final createdAt =
        DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String());
    final updatedAt =
        DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String());

    return RoutineTemplateDto(
      id: id,
      name: name,
      notes: notes,
      exerciseTemplates: exerciseTemplates,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
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
      // Only deep copy if a new list is provided
      exerciseTemplates: exerciseTemplates ?? this.exerciseTemplates,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'RoutineTemplateDto{id: $id, name: $name, notes: $notes, exerciseTemplates: $exerciseTemplates, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}

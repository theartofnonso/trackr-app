import 'dart:convert';

import 'exercise_log_dto.dart';

class RoutineLogDto {
  final String id;
  final String templateId;
  final String name;
  final String notes;
  final DateTime startTime;
  final DateTime endTime;
  final List<ExerciseLogDto> exerciseLogs;
  final DateTime createdAt;
  final DateTime updatedAt;

  RoutineLogDto({
    required this.id,
    required this.templateId,
    required this.name,
    required this.exerciseLogs,
    required this.notes,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
    required this.updatedAt,
  });

  Duration duration() {
    return endTime.difference(startTime);
  }

  factory RoutineLogDto.fromJson(Map<String, dynamic> json) {
    final id = json["id"] ?? "";
    final templateId = json["templateId"] ?? "";
    final name = json["name"] ?? "";
    final notes = json["notes"] ?? "";
    final startTime = DateTime.parse(json["startTime"]);
    final endTime = DateTime.parse(json["endTime"]);
    final exercisesJsons = json["exercises"] as List<dynamic>;
    final exercises = exercisesJsons.map((json) => ExerciseLogDto.fromJson(json: jsonDecode(json))).toList();
    final createdAt = DateTime.now();
    final updatedAt = DateTime.now();
    return RoutineLogDto(id: id, templateId: templateId, name: name, notes: notes, startTime: startTime, endTime: endTime, exerciseLogs: exercises, createdAt: createdAt, updatedAt: updatedAt);
  }

  RoutineLogDto copyWith({
    String? id,
    String? templateId,
    String? name,
    String? notes,
    DateTime? startTime,
    DateTime? endTime,
    List<ExerciseLogDto>? exerciseLogs,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoutineLogDto(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      exerciseLogs: exerciseLogs ?? this.exerciseLogs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

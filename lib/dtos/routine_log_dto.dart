import 'dart:convert';

import 'exercise_log_dto.dart';
import 'interface/log_interface.dart';

class RoutineLogDto implements Log {
  @override
  final String id;
  final String templateId;
  @override
  final String name;
  @override
  final String notes;
  final String? summary;
  @override
  final DateTime startTime;
  @override
  final DateTime endTime;
  final List<ExerciseLogDto> exerciseLogs;
  final String? owner;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  RoutineLogDto({
    required this.id,
    required this.templateId,
    required this.name,
    required this.exerciseLogs,
    required this.notes,
    this.summary,
    required this.startTime,
    required this.endTime,
    required this.owner,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  Duration duration() {
    return endTime.difference(startTime);
  }

  static Map<String, dynamic> toJson(RoutineLogDto log) {
    return {
      'id': log.id,
      'templateId': log.templateId,
      'name': log.name,
      'notes': log.notes,
      'summary': log.summary,
      'startTime': log.startTime.toIso8601String(),
      'endTime': log.endTime.toIso8601String(),
      'exercises': log.exerciseLogs.map((exercise) => ExerciseLogDto.toJson(exercise)).toList(),
    };
  }

  factory RoutineLogDto.fromJson(Map<String, dynamic> json, {String? owner}) {
    final id = json["id"] ?? "";
    final templateId = json["templateId"] ?? "";
    final name = json["name"] ?? "";
    final notes = json["notes"] ?? "";
    final summary = json["summary"];
    final startTime = DateTime.parse(json["startTime"]);
    final endTime = DateTime.parse(json["endTime"]);
    final exercisesJsons = json["exercises"] as List<dynamic>;
    final exercises =
        exercisesJsons.map((json) => ExerciseLogDto.fromJson(routineLogId: id, json: jsonDecode(json))).toList();
    final createdAt = DateTime.now();
    final updatedAt = DateTime.now();
    return RoutineLogDto(
      id: id,
      templateId: templateId,
      name: name,
      notes: notes,
      summary: summary,
      startTime: startTime,
      endTime: endTime,
      exerciseLogs: exercises,
      owner: owner ?? "",
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  RoutineLogDto copyWith({
    String? id,
    String? templateId,
    String? name,
    String? notes,
    String? summary,
    DateTime? startTime,
    DateTime? endTime,
    List<ExerciseLogDto>? exerciseLogs,
    String? owner,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoutineLogDto(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      summary: summary ?? this.summary,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      exerciseLogs: exerciseLogs ?? this.exerciseLogs,
      owner: owner ?? this.owner,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'RoutineLogDto{id: $id, templateId: $templateId, name: $name, notes: $notes, summary: $summary, startTime: $startTime, endTime: $endTime, exerciseLogs: $exerciseLogs, owner: $owner, createdAt: $createdAt, updatedAt: $updatedAt}';
  }

  @override
  LogType get type => LogType.routine;
}

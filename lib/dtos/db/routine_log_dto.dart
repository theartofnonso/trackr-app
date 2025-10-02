import 'package:collection/collection.dart';
import 'package:tracker_app/dtos/set_dtos/weight_and_reps_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';

import '../exercise_log_dto.dart';

class RoutineLogDto {
  final String id;

  final String templateId;

  final String name;

  final String notes;

  final String? summary;

  final DateTime startTime;

  final DateTime endTime;

  final List<ExerciseLogDto> exerciseLogs;

  final int readinessScore;

  final DateTime createdAt;

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
    this.readinessScore = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Duration duration() {
    return endTime.difference(startTime);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'templateId': templateId,
      'name': name,
      'notes': notes,
      'summary': summary ?? '',
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'exercises': exerciseLogs.map((exercise) => exercise.toJson()).toList(),
      'readiness': readinessScore,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory RoutineLogDto.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? '';
    final templateId = json['templateId'] ?? '';
    final name = json['name'] ?? '';
    final notes = json['notes'] ?? '';
    final summary = json['summary'];
    final startTime =
        DateTime.parse(json['startTime'] ?? DateTime.now().toIso8601String());
    final endTime =
        DateTime.parse(json['endTime'] ?? DateTime.now().toIso8601String());
    final exercisesJson = json['exercises'] as List<dynamic>? ?? [];
    final exerciseLogs = exercisesJson
        .map((exerciseJson) => ExerciseLogDto.fromJson(json: exerciseJson))
        .toList();
    final readinessScore = json['readiness'] ?? 0;
    final createdAt =
        DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String());
    final updatedAt =
        DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String());

    return RoutineLogDto(
      id: id,
      templateId: templateId,
      name: name,
      notes: notes,
      summary: summary,
      startTime: startTime,
      endTime: endTime,
      exerciseLogs: exerciseLogs,
      readinessScore: readinessScore,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory RoutineLogDto.fromCachedLog({required Map<String, dynamic> json}) {
    final templateId = json["templateId"] ?? "";
    final name = json["name"] ?? "";
    final notes = json["notes"] ?? "";
    final summary = json["summary"];
    final readinessScore = json["readinessScore"] ?? 0;
    final startTime = DateTime.parse(json["startTime"]);
    final endTime = DateTime.parse(json["endTime"]);
    final exerciseLogJsons = json["exercises"] as List<dynamic>;
    final exerciseLogs = exerciseLogJsons.map((json) {
      return ExerciseLogDto.fromJson(routineLogId: "", json: json);
    }).toList();
    return RoutineLogDto(
      id: "",
      templateId: templateId,
      name: name,
      exerciseLogs: exerciseLogs,
      notes: notes,
      summary: summary,
      startTime: startTime,
      endTime: endTime,
      readinessScore: readinessScore,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  RoutineLogDto copyWith({
    String? id,
    String? templateId,
    String? name,
    String? notes,
    String? summary,
    DateTime? startTime,
    DateTime? endTime,
    List<ExerciseLogDto>? exerciseLogs,
    int? readinessScore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoutineLogDto(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      summary: summary ?? this.summary,
      readinessScore: readinessScore ?? this.readinessScore,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      // Only deep copy if a new list is provided
      exerciseLogs: exerciseLogs ?? this.exerciseLogs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'RoutineLogDto{id: $id, templateId: $templateId, name: $name, notes: $notes, summary: $summary, readinessScore: $readinessScore, startTime: $startTime, endTime: $endTime, exerciseLogs: $exerciseLogs, createdAt: $createdAt, updatedAt: $updatedAt}';
  }

  double get volume =>
      exerciseLogs.expand((exerciseLog) => exerciseLog.sets).map((set) {
        return switch (set.type) {
          ExerciseType.weights => (set as WeightAndRepsSetDto).volume(),
          ExerciseType.bodyWeight => 0.0,
          ExerciseType.duration => 0.0,
        };
      }).sum;
}

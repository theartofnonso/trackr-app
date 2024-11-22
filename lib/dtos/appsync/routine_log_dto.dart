import 'dart:convert';

import '../../enums/activity_type_enums.dart';
import '../../models/RoutineLog.dart';
import '../abstract_class/log_class.dart';
import '../exercise_log_dto.dart';

class RoutineLogDto extends Log {
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
  final List<ExerciseLogDTO> exerciseLogs;
  final String owner;
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'templateId': templateId,
      'name': name,
      'notes': notes,
      'summary': summary,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'exercises': exerciseLogs.map((exercise) => exercise.toJson()).toList(),
    };
  }

  factory RoutineLogDto.toDto(RoutineLog log) {
    return RoutineLogDto.fromLog(log: log);
  }

  factory RoutineLogDto.fromCachedLog({required Map<String, dynamic> json}) {
    final templateId = json["templateId"] ?? "";
    final name = json["name"] ?? "";
    final notes = json["notes"] ?? "";
    final summary = json["summary"];
    final startTime = DateTime.parse(json["startTime"]);
    final endTime = DateTime.parse(json["endTime"]);
    final exerciseLogJsons = json["exercises"] as List<dynamic>;
    final exerciseLogs = exerciseLogJsons.map((json) {
      return ExerciseLogDTO.fromJson(routineLogId: "", json: json);
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
      owner: "",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  factory RoutineLogDto.fromLog({required RoutineLog log}) {
    final json = jsonDecode(log.data);

    final templateId = json["templateId"] ?? "";
    final name = json["name"] ?? "";
    final notes = json["notes"] ?? "";
    final summary = json["summary"];
    final startTime = DateTime.parse(json["startTime"]);
    final endTime = DateTime.parse(json["endTime"]);
    final exerciseLogsInJson = json["exercises"] as List<dynamic>;
    List<ExerciseLogDTO> exerciseLogs = [];
    if (exerciseLogsInJson.isNotEmpty && exerciseLogsInJson.first is String) {
      final newSchema = _transformOldExercisesSchema(oldExercises: exerciseLogsInJson);

      exerciseLogs = newSchema
          .map((json) =>
              ExerciseLogDTO.fromJson(routineLogId: log.id, createdAt: log.createdAt.getDateTimeInUtc(), json: json))
          .toList();
    } else {
      exerciseLogs = exerciseLogsInJson
          .map((json) =>
              ExerciseLogDTO.fromJson(routineLogId: log.id, createdAt: log.createdAt.getDateTimeInUtc(), json: json))
          .toList();
    }

    return RoutineLogDto(
      id: log.id,
      templateId: templateId,
      name: name,
      exerciseLogs: exerciseLogs,
      notes: notes,
      summary: summary,
      startTime: startTime,
      endTime: endTime,
      owner: log.owner ?? "",
      createdAt: log.createdAt.getDateTimeInUtc(),
      updatedAt: log.updatedAt.getDateTimeInUtc(),
    );
  }

  static List<Map<String, dynamic>> _transformOldExercisesSchema({required List<dynamic> oldExercises}) {
    // Process exercises
    List<Map<String, dynamic>> newExercises = [];

    for (final exerciseStr in oldExercises) {
      // The exercises are strings of JSON objects, so parse them
      Map<String, dynamic> oldExercise = jsonDecode(exerciseStr);

      // Initialize new exercise map
      Map<String, dynamic> newExercise = {
        'notes': oldExercise['notes'] ?? '',
        'sets': [],
        'superSetId': oldExercise['superSetId'] ?? '',
        'exercise': {
          'secondary_muscle_groups': oldExercise['exercise']['secondaryMuscleGroups'] ?? [],
          'base_exercise_id': oldExercise['exercise']['id'] ?? '',
          'primary_muscle_groups': [oldExercise['exercise']['primaryMuscleGroup'] ?? ''],
          'configurations': <String, dynamic>{},
          'name': oldExercise['exercise']['name'] ?? '',
        },
      };

      // Process sets
      List<dynamic> oldSets = oldExercise['sets'] ?? [];
      List<dynamic> newSets = [];

      for (var setStr in oldSets) {
        // The sets are strings of JSON objects, so parse them
        Map<String, dynamic> oldSet = jsonDecode(setStr);

        // Map old set fields to new set fields
        Map<String, dynamic> newSet = {
          'value1': oldSet['value1'] ?? 0,
          'value2': oldSet['value2'] ?? 0,
          'checked': oldSet['checked'] ?? false,
        };

        newSets.add(newSet);
      }

      newExercise['sets'] = newSets;

      newExercises.add(newExercise);
    }

    return newExercises;
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
    List<ExerciseLogDTO>? exerciseLogs,
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
  LogType get logType => LogType.routine;

  @override
  ActivityType get activityType => ActivityType.weightlifting;
}

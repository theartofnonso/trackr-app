import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:tracker_app/dtos/set_dtos/weight_and_reps_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';

import '../../models/RoutineLog.dart';
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

  final String owner;

  final int fatigueLevel;

  final int sorenessLevel;

  final int sleepLevel;

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
    required this.owner,
    this.fatigueLevel = 0,
    this.sorenessLevel = 0,
    this.sleepLevel = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Duration duration() {
    return endTime.difference(startTime);
  }

  Map<String, Object> toJson() {
    return {
      'id': id,
      'templateId': templateId,
      'name': name,
      'notes': notes,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'exercises': exerciseLogs.map((exercise) => exercise.toJson()).toList(),
      'fatigueLevel': fatigueLevel,
      'sorenessLevel': sorenessLevel,
      'sleepLevel': sleepLevel
    };
  }

  factory RoutineLogDto.toDto(RoutineLog log) {
    return RoutineLogDto.fromLog(log: log);
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
    final fatigueLevel = json["fatigueLevel"] ?? 0;
    final sorenessLevel = json["sorenessLevel"] ?? 0;
    final sleepLevel = json["sleepLevel"] ?? 0;
    List<ExerciseLogDto> exerciseLogs = [];
    if (exerciseLogsInJson.isNotEmpty && exerciseLogsInJson.first is String) {
      exerciseLogs = exerciseLogsInJson
          .map((json) => ExerciseLogDto.fromJson(
              routineLogId: log.id, json: jsonDecode(json), createdAt: log.createdAt.getDateTimeInUtc()))
          .toList();
    } else {
      exerciseLogs = exerciseLogsInJson
          .map((json) =>
              ExerciseLogDto.fromJson(routineLogId: log.id, createdAt: log.createdAt.getDateTimeInUtc(), json: json))
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
      fatigueLevel: fatigueLevel,
      sorenessLevel: sorenessLevel,
      sleepLevel: sleepLevel,
      createdAt: log.createdAt.getDateTimeInUtc(),
      updatedAt: log.updatedAt.getDateTimeInUtc(),
    );
  }

  factory RoutineLogDto.fromCachedLog({required Map<String, dynamic> json}) {
    final templateId = json["templateId"] ?? "";
    final name = json["name"] ?? "";
    final notes = json["notes"] ?? "";
    final summary = json["summary"];
    final fatigueLevel = json["fatigueLevel"] ?? 0;
    final sorenessLevel = json["sorenessLevel"] ?? 0;
    final sleepLevel = json["sleepLevel"] ?? 0;
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
      owner: "",
      fatigueLevel: fatigueLevel,
      sorenessLevel: sorenessLevel,
      sleepLevel: sleepLevel,
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
    String? owner,
    int? fatigueLevel,
    int? sorenessLevel,
    int? sleepLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoutineLogDto(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      summary: summary ?? this.summary,
      fatigueLevel: fatigueLevel ?? this.fatigueLevel,
      sorenessLevel: sorenessLevel ?? this.sorenessLevel,
      sleepLevel: sleepLevel ?? this.sleepLevel,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      // Deep copy the list. For any new list passed in, we clone its items;
      // otherwise, we clone the existing list if it's not null.
      exerciseLogs: exerciseLogs != null
          ? exerciseLogs.map((e) => e.copyWith()).toList()
          : this.exerciseLogs.map((e) => e.copyWith()).toList(),
      owner: owner ?? this.owner,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'RoutineLogDto{id: $id, templateId: $templateId, name: $name, notes: $notes, summary: $summary, fatigueLevel: $fatigueLevel, sorenessLevel: $sorenessLevel, sleepLevel: $sleepLevel, startTime: $startTime, endTime: $endTime, exerciseLogs: $exerciseLogs, owner: $owner, createdAt: $createdAt, updatedAt: $updatedAt}';
  }

  double get volume => exerciseLogs.expand((exerciseLog) => exerciseLog.sets).map((set) {
        return switch (set.type) {
          ExerciseType.weights => (set as WeightAndRepsSetDto).volume(),
          ExerciseType.bodyWeight => 0.0,
          ExerciseType.duration => 0.0,
        };
      }).sum;
}

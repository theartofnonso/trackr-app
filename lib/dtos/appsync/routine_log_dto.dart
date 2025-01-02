import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:tracker_app/dtos/set_dtos/weight_and_reps_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';

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

  final List<ExerciseLogDto> exerciseLogs;

  final String owner;

  final DateTime? sleepFrom;

  final DateTime? sleepTo;

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
    this.sleepFrom,
    this.sleepTo,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  Duration duration() {
    return endTime.difference(startTime);
  }

  Map<String, Object> toJson() {
    return {
      'id': id,
      'templateId': templateId,
      'name': name,
      'notes': notes,
      'sleepFrom': sleepFrom?.toIso8601String() ?? "",
      'sleepTo': sleepTo?.toIso8601String() ?? "",
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'exercises': exerciseLogs.map((exercise) => exercise.toJson()).toList(),
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
    final sleepFrom = DateTime.tryParse(json["sleepFrom"] ?? "");
    final sleepTo = DateTime.tryParse(json["sleepTo"] ?? "");
    final startTime = DateTime.parse(json["startTime"]);
    final endTime = DateTime.parse(json["endTime"]);
    final exerciseLogsInJson = json["exercises"] as List<dynamic>;
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
      sleepFrom: sleepFrom,
      sleepTo: sleepTo,
      createdAt: log.createdAt.getDateTimeInUtc(),
      updatedAt: log.updatedAt.getDateTimeInUtc(),
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
    DateTime? sleepFrom,
    DateTime? sleepTo,
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
      // Deep copy the list. For any new list passed in, we clone its items;
      // otherwise, we clone the existing list if it's not null.
      exerciseLogs: exerciseLogs != null
          ? exerciseLogs.map((e) => e.copyWith()).toList()
          : this.exerciseLogs.map((e) => e.copyWith()).toList(),
      owner: owner ?? this.owner,
      sleepFrom: sleepFrom ?? this.sleepFrom,
      sleepTo: sleepTo ?? this.sleepTo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'RoutineLogDto{id: $id, templateId: $templateId, name: $name, notes: $notes, summary: $summary, startTime: $startTime, endTime: $endTime, exerciseLogs: $exerciseLogs, owner: $owner, sleepFrom: $sleepFrom, sleepTo: $sleepTo, createdAt: $createdAt, updatedAt: $updatedAt}';
  }

  @override
  LogType get logType => LogType.routine;

  @override
  ActivityType get activityType => ActivityType.weightlifting;

  double get volume => exerciseLogs.expand((exerciseLog) => exerciseLog.sets).map((set) {
        return switch (set.type) {
          ExerciseType.weights => (set as WeightAndRepsSetDto).volume(),
          ExerciseType.bodyWeight => 0.0,
          ExerciseType.duration => 0.0,
        };
      }).sum;
}

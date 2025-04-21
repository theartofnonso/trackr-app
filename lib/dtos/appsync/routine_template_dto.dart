import 'dart:convert';

import 'package:tracker_app/dtos/appsync/routine_log_dto.dart';
import 'package:tracker_app/models/ModelProvider.dart';

import '../../models/RoutineTemplate.dart';
import '../exercise_log_dto.dart';

class RoutineTemplateDto {
  final String id;
  final String name;
  final String notes;
  final List<ExerciseLogDto> exerciseTemplates;
  final String owner;
  final DateTime createdAt;
  final DateTime updatedAt;

  RoutineTemplateDto({
    required this.id,
    required this.name,
    required this.exerciseTemplates,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.owner,
  });

  Map<String, Object> toJson() {
    return {
      "id": id,
      'name': name,
      'notes': notes,
      'exercises': exerciseTemplates.map((exercise) => exercise.toJson()).toList(),
    };
  }

  factory RoutineTemplateDto.toDto(RoutineTemplate template) {
    return RoutineTemplateDto.fromTemplate(template: template);
  }

  factory RoutineTemplateDto.fromTemplate({required RoutineTemplate template}) {
    final json = jsonDecode(template.data);
    final name = json["name"] ?? "";
    final notes = json["notes"] ?? "";
    final exerciseTemplatesInJson = json["exercises"] as List<dynamic>;
    List<ExerciseLogDto> exerciseTemplates = [];
    if (exerciseTemplatesInJson.isNotEmpty && exerciseTemplatesInJson.first is String) {
      exerciseTemplates = exerciseTemplatesInJson
          .map((json) => ExerciseLogDto.fromJson(
              routineLogId: template.id, json: jsonDecode(json), createdAt: template.createdAt.getDateTimeInUtc()))
          .toList();
    } else {
      exerciseTemplates = exerciseTemplatesInJson
          .map((json) => ExerciseLogDto.fromJson(
              routineLogId: template.id, createdAt: template.createdAt.getDateTimeInUtc(), json: json))
          .toList();
    }

    return RoutineTemplateDto(
      id: template.id,
      name: name,
      exerciseTemplates: exerciseTemplates,
      notes: notes,
      owner: template.owner ?? "",
      createdAt: template.createdAt.getDateTimeInUtc(),
      updatedAt: template.updatedAt.getDateTimeInUtc(),
    );
  }

  factory RoutineTemplateDto.fromDto({required RoutinePlan plan, required dynamic json}) {
    final id = plan.id;
    final name = json["name"] ?? "";
    final notes = json["notes"] ?? "";
    final exerciseTemplatesInJson = json["exercises"] as List<dynamic>;
    List<ExerciseLogDto> exerciseTemplates = [];
    if (exerciseTemplatesInJson.isNotEmpty && exerciseTemplatesInJson.first is String) {
      exerciseTemplates = exerciseTemplatesInJson
          .map((json) => ExerciseLogDto.fromJson(
          routineLogId: id, json: jsonDecode(json), createdAt: plan.createdAt.getDateTimeInUtc()))
          .toList();
    } else {
      exerciseTemplates = exerciseTemplatesInJson
          .map((json) => ExerciseLogDto.fromJson(
          routineLogId: id, createdAt: plan.createdAt.getDateTimeInUtc(), json: json))
          .toList();
    }

    return RoutineTemplateDto(
      id: id,
      name: name,
      exerciseTemplates: exerciseTemplates,
      notes: notes,
      owner: plan.owner ?? "",
      createdAt: plan.createdAt.getDateTimeInUtc(),
      updatedAt: plan.updatedAt.getDateTimeInUtc(),
    );
  }

  RoutineLogDto toLog() {
    return RoutineLogDto(
        id: "",
        templateId: id,
        name: name,
        exerciseLogs: List.from(exerciseTemplates),
        notes: notes,
        owner: owner,
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
    String? owner,
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
      owner: owner ?? this.owner,
    );
  }

  @override
  String toString() {
    return 'RoutineTemplateDto{id: $id, name: $name, notes: $notes, exerciseTemplates: $exerciseTemplates, owner: $owner, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}

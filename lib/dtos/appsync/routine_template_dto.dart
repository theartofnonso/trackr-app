import 'dart:convert';

import 'package:tracker_app/dtos/appsync/routine_log_dto.dart';
import 'package:tracker_app/dtos/appsync/routine_plan_dto.dart';
import 'package:tracker_app/models/ModelProvider.dart';

import '../exercise_log_dto.dart';

class RoutineTemplateDto {
  final String id;
  final String planId;
  final String name;
  final String notes;
  final List<ExerciseLogDto> exerciseTemplates;
  final String owner;
  final DateTime createdAt;
  final DateTime updatedAt;

  RoutineTemplateDto({
    required this.id,
    this.planId = "",
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
      "planId": planId,
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
    final String? rawPlanId = json['planId'] as String?;
    final String planId = (rawPlanId?.isNotEmpty ?? false) ? rawPlanId! : defaultPlanId;
    final name = json["name"] ?? "";
    final notes = json["notes"] ?? "";
    final rawExerciseTemplates = json["exercises"] as List<dynamic>;
    List<ExerciseLogDto> exerciseTemplates = [];
    if (rawExerciseTemplates.isNotEmpty && rawExerciseTemplates.first is String) {
      exerciseTemplates = rawExerciseTemplates
          .map((json) => ExerciseLogDto.fromJson(
              routineLogId: template.id, json: jsonDecode(json), createdAt: template.createdAt.getDateTimeInUtc()))
          .toList();
    } else {
      exerciseTemplates = rawExerciseTemplates
          .map((json) => ExerciseLogDto.fromJson(
              routineLogId: template.id, createdAt: template.createdAt.getDateTimeInUtc(), json: json))
          .toList();
    }

    return RoutineTemplateDto(
      id: template.id,
      planId: planId,
      name: name,
      exerciseTemplates: exerciseTemplates,
      notes: notes,
      owner: template.owner ?? "",
      createdAt: template.createdAt.getDateTimeInUtc(),
      updatedAt: template.updatedAt.getDateTimeInUtc(),
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
    String? planId,
    String? name,
    String? notes,
    List<ExerciseLogDto>? exerciseTemplates,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? owner,
  }) {
    return RoutineTemplateDto(
      id: id ?? this.id,
      planId: planId ?? this.planId,
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
    return 'RoutineTemplateDto{id: $id, planId: $planId, name: $name, notes: $notes, exerciseTemplates: $exerciseTemplates, owner: $owner, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}

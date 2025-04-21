import 'dart:convert';

import 'package:tracker_app/dtos/appsync/routine_template_dto.dart';

import '../../models/RoutinePlan.dart';

class RoutinePlanDto {
  final String id;
  final String name;
  final String notes;
  final List<RoutineTemplateDto> routineTemplates;
  final String owner;
  final DateTime createdAt;
  final DateTime updatedAt;

  RoutinePlanDto({
    required this.id,
    required this.name,
    required this.routineTemplates,
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
      'templates': routineTemplates.map((exercise) => exercise.toJson()).toList(),
    };
  }

  factory RoutinePlanDto.toDto(RoutinePlan plan) {
    return RoutinePlanDto.fromPlan(plan: plan);
  }

  factory RoutinePlanDto.fromPlan({required RoutinePlan plan}) {
    final json = jsonDecode(plan.data);
    final name = json["name"] ?? "";
    final notes = json["notes"] ?? "";
    final routineTemplatesInJson = json["templates"] as List<dynamic>;
    List<RoutineTemplateDto> routineTemplates = routineTemplatesInJson.map((json) {
      return RoutineTemplateDto.fromDto(plan: plan, json: json,);
    }).toList();

    return RoutinePlanDto(
      id: plan.id,
      name: name,
      routineTemplates: routineTemplates,
      notes: notes,
      owner: plan.owner ?? "",
      createdAt: plan.createdAt.getDateTimeInUtc(),
      updatedAt: plan.updatedAt.getDateTimeInUtc(),
    );
  }

  RoutinePlanDto copyWith({
    String? id,
    String? name,
    String? notes,
    List<RoutineTemplateDto>? routineTemplates,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? owner,
  }) {
    return RoutinePlanDto(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      // Deep copy each ExerciseLogDto.
      routineTemplates: routineTemplates != null
          ? routineTemplates.map((e) => e.copyWith()).toList()
          : this.routineTemplates.map((e) => e.copyWith()).toList(),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      owner: owner ?? this.owner,
    );
  }

  @override
  String toString() {
    return 'RoutinePlanDto{id: $id, name: $name, notes: $notes, routineTemplates: $routineTemplates, owner: $owner, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}

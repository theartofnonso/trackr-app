import 'dart:convert';

import 'package:tracker_app/dtos/appsync/routine_template_dto.dart';

import '../../models/RoutinePlan.dart';
import '../../models/RoutineTemplate.dart';

class RoutinePlanDto {
  final String id;
  final String name;
  final String notes;
  final int length;
  final List<RoutineTemplateDto> routineTemplates;
  final String owner;
  final DateTime createdAt;
  final DateTime updatedAt;

  RoutinePlanDto({
    required this.id,
    required this.name,
    required this.routineTemplates,
    required this.notes,
    required this.length,
    required this.createdAt,
    required this.updatedAt,
    required this.owner,
  });

  Map<String, Object> toJson() {
    return {
      "id": id,
      'name': name,
      'notes': notes,
      'length': length,
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
    final length = json["length"] ?? "";
    final routineTemplatesInJson = json["templates"] as List<dynamic>;
    List<RoutineTemplateDto> routineTemplates = routineTemplatesInJson.map((json) {
      final template = RoutineTemplate.fromJson(json);
      return RoutineTemplateDto.fromTemplate(template: template);
    }).toList();

    return RoutinePlanDto(
      id: plan.id,
      name: name,
      routineTemplates: routineTemplates,
      notes: notes,
      length: length,
      owner: plan.owner ?? "",
      createdAt: plan.createdAt.getDateTimeInUtc(),
      updatedAt: plan.updatedAt.getDateTimeInUtc(),
    );
  }

  RoutinePlanDto copyWith({
    String? id,
    String? name,
    String? notes,
    int? length,
    List<RoutineTemplateDto>? routineTemplates,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? owner,
  }) {
    return RoutinePlanDto(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      length: length ?? this.length,
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
    return 'RoutinePlanDto{id: $id, name: $name, notes: $notes, length: $length, routineTemplates: $routineTemplates, owner: $owner, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}

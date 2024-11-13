import 'dart:convert';

import 'package:tracker_app/dtos/appsync/routine_template_dto.dart';

import '../../models/RoutineTemplate.dart';
import '../../models/RoutineTemplatePlan.dart';

class RoutineTemplatePlanDto {
  final String id;
  final String name;
  final String notes;
  final List<RoutineTemplateDto> templates;
  final int weeks;
  final String owner;
  final DateTime createdAt;
  final DateTime updatedAt;

  RoutineTemplatePlanDto(
      {required this.id,
      required this.name,
      required this.notes,
      required this.templates,
      required this.weeks,
      required this.owner,
      required this.createdAt,
      required this.updatedAt});

  factory RoutineTemplatePlanDto.toDto(RoutineTemplatePlan templatePlan) {
    final json = jsonDecode(templatePlan.data);
    return RoutineTemplatePlanDto.fromJson(json);
  }

  factory RoutineTemplatePlanDto.fromJson(Map<String, dynamic> data) {
    final routineTemplatePlan = RoutineTemplatePlan.fromJson(data);
    final dataJson = jsonDecode(routineTemplatePlan.data);
    final name = dataJson["name"] ?? "";
    final notes = dataJson["notes"] ?? "";
    final weeks = dataJson["weeks"] ?? 0;
    final templateJsons = dataJson["templates"] as List<dynamic>;
    final templates = templateJsons.map((json) {
      final template = RoutineTemplate.fromJson(json);
      return RoutineTemplateDto.fromTemplate(template: template);
    }).toList();

    return RoutineTemplatePlanDto(
      id: routineTemplatePlan.id,
      name: name,
      notes: notes,
      templates: templates,
      weeks: weeks,
      owner: routineTemplatePlan.owner ?? "",
      createdAt: routineTemplatePlan.createdAt.getDateTimeInUtc(),
      updatedAt: routineTemplatePlan.updatedAt.getDateTimeInUtc(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'notes': notes,
      'templates': templates.map((template) => template.toJson()).toList(),
      'weeks': weeks,
    };
  }

  RoutineTemplatePlanDto copyWith(
      {String? id,
      String? name,
      String? notes,
      List<RoutineTemplateDto>? templates,
      int? weeks,
      DateTime? createdAt,
      DateTime? updatedAt,
      String? owner}) {
    return RoutineTemplatePlanDto(
        id: id ?? this.id,
        name: name ?? this.name,
        notes: notes ?? this.notes,
        templates: templates ?? this.templates,
        weeks: weeks ?? this.weeks,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        owner: owner ?? this.owner);
  }

  @override
  String toString() {
    return 'RoutineTemplatePlan{id: $id, name: $name, notes: $notes, templates: $templates, weeks: $weeks, owner: $owner, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}

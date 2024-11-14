import 'dart:convert';

import 'package:tracker_app/dtos/appsync/routine_template_dto.dart';
import 'package:tracker_app/models/ModelProvider.dart';

class RoutineTemplatePlanDto {
  final String id;
  final String name;
  final String notes;
  final List<RoutineTemplateDto>? templates;
  final int weeks;
  final String owner;
  final DateTime createdAt;
  final DateTime updatedAt;

  RoutineTemplatePlanDto(
      {required this.id,
      required this.name,
      required this.notes,
      this.templates,
      required this.weeks,
      required this.owner,
      required this.createdAt,
      required this.updatedAt});

  factory RoutineTemplatePlanDto.toDto(RoutineTemplatePlan templatePlan, {required List<RoutineTemplate> templates}) {
    return RoutineTemplatePlanDto.fromTemplate(templatePlan: templatePlan, templates: templates);
  }

  factory RoutineTemplatePlanDto.fromTemplate(
      {required RoutineTemplatePlan templatePlan, required List<RoutineTemplate> templates}) {
    final json = jsonDecode(templatePlan.data);
    final name = json["name"] ?? "";
    final notes = json["notes"] ?? "";
    final weeks = json["weeks"] ?? 0;
    final templateDtos = templates.map((template) {
      return RoutineTemplateDto.fromTemplate(template: template);
    }).toList();

    return RoutineTemplatePlanDto(
      id: templatePlan.id,
      name: name,
      notes: notes,
      templates: templateDtos,
      weeks: weeks,
      owner: templatePlan.owner ?? "",
      createdAt: templatePlan.createdAt.getDateTimeInUtc(),
      updatedAt: templatePlan.updatedAt.getDateTimeInUtc(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'notes': notes,
      'templates': templates?.map((template) => template.toJson()).toList(),
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

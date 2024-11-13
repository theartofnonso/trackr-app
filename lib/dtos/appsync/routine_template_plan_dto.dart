import 'package:tracker_app/dtos/appsync/routine_template_dto.dart';

class RoutineTemplatePlanDto {
  final String id;
  final String name;
  final String notes;
  final List<RoutineTemplateDto> templates;
  final String owner;
  final DateTime createdAt;
  final DateTime updatedAt;

  RoutineTemplatePlanDto({required this.id, required this.name, required this.notes, required this.templates, required this.owner, required this.createdAt, required this.updatedAt});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'notes': notes,
      'templates': templates.map((template) => template.toJson()).toList(),
    };
  }

  RoutineTemplatePlanDto copyWith(
      {String? id, String? name, String? notes, List<RoutineTemplateDto>? templates, DateTime? createdAt, DateTime? updatedAt, String? owner}) {
    return RoutineTemplatePlanDto(
      id: id ?? this.id,
      name: name ?? this.name,
        notes: notes ?? this.notes,
        templates: templates ?? this.templates,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        owner: owner ?? this.owner);
  }

  @override
  String toString() {
    return 'RoutineTemplatePlan{id: $id, name: $name, notes: $notes, templates: $templates, owner: $owner, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}

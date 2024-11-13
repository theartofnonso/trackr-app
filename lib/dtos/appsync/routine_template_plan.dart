import 'package:tracker_app/dtos/appsync/routine_template_dto.dart';

class RoutineTemplatePlan {
  final List<RoutineTemplateDto> templates;
  final String owner;
  final DateTime createdAt;
  final DateTime updatedAt;

  RoutineTemplatePlan({required this.templates, required this.owner, required this.createdAt, required this.updatedAt});

  Map<String, dynamic> toJson() {
    return {
      'templates': templates.map((template) => template.toJson()).toList(),
    };
  }

  RoutineTemplatePlan copyWith(
      {String? id, List<RoutineTemplateDto>? templates, DateTime? createdAt, DateTime? updatedAt, String? owner}) {
    return RoutineTemplatePlan(
        templates: templates ?? this.templates,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        owner: owner ?? this.owner);
  }

  @override
  String toString() {
    return 'RoutineTemplatePlan{templates: $templates, owner: $owner, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}

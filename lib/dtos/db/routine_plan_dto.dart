import 'routine_template_dto.dart';

class RoutinePlanDto {
  final String id;
  final String name;
  final String notes;
  final List<RoutineTemplateDto> templates;
  final DateTime createdAt;
  final DateTime updatedAt;

  RoutinePlanDto({
    required this.id,
    required this.name,
    required this.notes,
    required this.templates,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'notes': notes,
      'templates': templates.map((template) => template.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  RoutinePlanDto copyWith({
    String? id,
    String? name,
    String? notes,
    List<RoutineTemplateDto>? templates,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoutinePlanDto(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      templates: templates ?? this.templates,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'RoutinePlanDto{id: $id, name: $name, notes: $notes, templates: $templates, createdAt: $createdAt, updatedAt: $updatedAt}';
  }

  @override
  bool operator ==(Object other) {
    return other is RoutinePlanDto && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

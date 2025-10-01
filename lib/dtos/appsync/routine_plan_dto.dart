class RoutinePlanDto {
  final String id;
  final String name;
  final String notes;
  final String owner;
  final DateTime createdAt;
  final DateTime updatedAt;

  RoutinePlanDto({
    required this.id,
    required this.name,
    required this.notes,
    required this.owner,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'notes': notes,
      'owner': owner,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  RoutinePlanDto copyWith({
    String? id,
    String? name,
    String? notes,
    String? owner,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoutinePlanDto(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      owner: owner ?? this.owner,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'RoutinePlanDto{id: $id, name: $name, notes: $notes, owner: $owner, createdAt: $createdAt, updatedAt: $updatedAt}';
  }

  @override
  bool operator ==(Object other) {
    return other is RoutinePlanDto && other.id == id;
  }
}

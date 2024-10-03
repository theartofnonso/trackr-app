class ActivityLogDto {
  final String id;
  final String name;
  final String notes;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  ActivityLogDto({
    required this.id,
    required this.name,
    required this.notes,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
    required this.updatedAt,
  });

  Duration duration() {
    return endTime.difference(startTime);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'notes': notes,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
    };
  }

  factory ActivityLogDto.fromJson(Map<String, dynamic> json) {
    final id = json["id"] ?? "";
    final name = json["name"] ?? "";
    final notes = json["notes"] ?? "";
    final startTime = DateTime.parse(json["startTime"]);
    final endTime = DateTime.parse(json["endTime"]);
    final createdAt = DateTime.now();
    final updatedAt = DateTime.now();
    return ActivityLogDto(
        id: id,
        name: name,
        notes: notes,
        startTime: startTime,
        endTime: endTime,
        createdAt: createdAt,
        updatedAt: updatedAt);
  }

  ActivityLogDto copyWith({
    String? id,
    String? name,
    String? notes,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ActivityLogDto(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ActivityLogDto{id: $id, name: $name, notes: $notes, startTime: $startTime, endTime: $endTime, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}

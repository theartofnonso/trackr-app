import 'interface/log_interface.dart';

class ActivityLogDto implements Log {
  @override
  final String id;
  @override
  final String name;
  @override
  final String notes;
  @override
  final DateTime startTime;
  @override
  final DateTime endTime;
  final String owner;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  ActivityLogDto({
    required this.id,
    required this.name,
    required this.notes,
    required this.startTime,
    required this.endTime,
    required this.owner,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
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

  @override
  ActivityLogDto copyWith({
    String? id,
    String? name,
    String? notes,
    DateTime? startTime,
    DateTime? endTime,
    String? owner,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ActivityLogDto(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      owner: owner ?? this.owner,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ActivityLogDto{id: $id, name: $name, notes: $notes, startTime: $startTime, endTime: $endTime, createdAt: $createdAt, updatedAt: $updatedAt}';
  }

  @override
  // TODO: implement type
  LogType get type => LogType.activity;
}

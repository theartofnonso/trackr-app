import 'dart:convert';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:uuid/uuid.dart';

import 'exercise_dto.dart';

class ExerciseLogDto {
  final String id;
  final String? routineLogId;
  final String superSetId;
  final ExerciseDto exercise;
  final String notes;
  final List<SetDto> sets;
  final DateTime createdAt;

  const ExerciseLogDto(
      this.id, this.routineLogId, this.superSetId, this.exercise, this.notes, this.sets, this.createdAt);

  String toJson() {
    final setJsons = sets.map((set) => set.toJson()).toList();

    return jsonEncode({"superSetId": superSetId, "exercise": exercise.toJson(), "notes": notes, "sets": setJsons});
  }

  ExerciseLogDto copyWith(
      {String? id,
      String? routineLogId,
      String? superSetId,
      String? exerciseId,
      ExerciseDto? exercise,
      String? notes,
      List<SetDto>? sets,
      DateTime? createdAt}) {
    return ExerciseLogDto(
      id ?? this.id,
      routineLogId ?? this.routineLogId,
      superSetId ?? this.superSetId,
      exercise ?? this.exercise,
      notes ?? this.notes,
      sets ?? this.sets,
      createdAt ?? this.createdAt,
    );
  }

  factory ExerciseLogDto.fromJson({String? routineLogId, DateTime? createdAt, required Map<String, dynamic> json}) {
    final superSetId = json["superSetId"] ?? "";
    final exerciseJson = json["exercise"];
    final exercise = ExerciseDto.fromJson(exerciseJson);
    final notes = json["notes"] ?? "";
    final setsJsons = json["sets"] as List<dynamic>;
    final sets = setsJsons.map((json) => SetDto.fromJson(jsonDecode(json))).toList();
    return ExerciseLogDto(
        const Uuid().v4(), routineLogId, superSetId, exercise, notes, sets, createdAt ?? DateTime.now());
  }

  @override
  String toString() {
    return 'ExerciseLogDto{id: $id, routineLogId: $routineLogId, superSetId: $superSetId, exercise: $exercise, notes: $notes, sets: $sets, createdAt: $createdAt}';
  }
}

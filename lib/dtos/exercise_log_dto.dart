import 'dart:convert';

import 'package:tracker_app/dtos/set_dtos/set_dto.dart';

import 'db/exercise_dto.dart';

class ExerciseLogDto {
  final String id;
  final String? routineLogId;
  final String superSetId;
  final ExerciseDto exercise;
  final String notes;
  final List<SetDto> sets;
  final DateTime createdAt;

  const ExerciseLogDto(
      {required this.id,
      required this.routineLogId,
      required this.superSetId,
      required this.exercise,
      required this.notes,
      required this.sets,
      required this.createdAt});

  Map<String, dynamic> toJson() {
    final setJsons = sets.map((set) => set.toJson()).toList();

    return {
      "superSetId": superSetId,
      "exercise": exercise.toJson(),
      "notes": notes,
      "sets": setJsons,
    };
  }

  ExerciseLogDto copyWith({
    String? id,
    String? routineLogId,
    String? superSetId,
    ExerciseDto? exercise,
    String? notes,
    List<SetDto>? sets,
    DateTime? createdAt,
  }) {
    return ExerciseLogDto(
      id: id ?? this.id,
      routineLogId: routineLogId ?? this.routineLogId,
      superSetId: superSetId ?? this.superSetId,

      // Only deep copy if new values are provided
      exercise: exercise ?? this.exercise,
      notes: notes ?? this.notes,
      sets: sets ?? this.sets,

      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ExerciseLogDto.fromJson(
      {String? routineLogId,
      DateTime? createdAt,
      required Map<String, dynamic> json}) {
    final id = json["id"] ?? "";
    final superSetId = json["superSetId"] ?? "";
    final exerciseJson = json["exercise"];
    final exercise = ExerciseDto.fromJson(exerciseJson);
    final notes = json["notes"] ?? "";
    final setsInJsons = json["sets"] as List<dynamic>;
    List<SetDto> sets = [];
    if (setsInJsons.isNotEmpty && setsInJsons.first is String) {
      sets = setsInJsons
          .map((json) => SetDto.fromJson(jsonDecode(json),
              exerciseType: exercise.type,
              datetime: createdAt ?? DateTime.now()))
          .toList();
    } else {
      sets = setsInJsons
          .map((json) => SetDto.fromJson(json,
              exerciseType: exercise.type,
              datetime: createdAt ?? DateTime.now()))
          .toList();
    }

    final exerciseLog = ExerciseLogDto(
        id: id,
        routineLogId: routineLogId,
        superSetId: superSetId,
        exercise: exercise,
        notes: notes,
        sets: sets,
        createdAt: createdAt ?? DateTime.now());

    return exerciseLog;
  }

  @override
  String toString() {
    return 'ExerciseLogDto{id: $id, routineLogId: $routineLogId, superSetId: $superSetId, exercise: $exercise, notes: $notes, sets: $sets, createdAt: $createdAt}';
  }
}

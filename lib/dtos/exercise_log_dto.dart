import 'dart:convert';

import 'package:tracker_app/dtos/set_dtos/set_dto.dart';

import 'appsync/exercise_dto.dart';

class ExerciseLogDto {
  final String id;
  final String? routineLogId;
  final String superSetId;
  final ExerciseDto exercise;
  final int maxReps;
  final int minReps;
  final String notes;
  final List<SetDto> sets;
  final DateTime createdAt;

  const ExerciseLogDto(
      {required this.id,
      required this.routineLogId,
      required this.superSetId,
      required this.exercise,
      this.maxReps = 0,
      this.minReps = 0,
      required this.notes,
      required this.sets,
      required this.createdAt});

  Map<String, dynamic> toJson() {
    final setJsons = sets.map((set) => set.toJson()).toList();

    return {
      "superSetId": superSetId,
      "exercise": exercise.toJson(),
      "minReps": minReps,
      "maxReps": maxReps,
      "notes": notes,
      "sets": setJsons,
    };
  }

  ExerciseLogDto copyWith(
      {String? id,
      String? routineLogId,
      String? superSetId,
      String? exerciseId,
      ExerciseDto? exercise,
      int? minReps,
      int? maxReps,
      String? notes,
      List<SetDto>? sets,
      DateTime? createdAt}) {
    return ExerciseLogDto(
        id: id ?? this.id,
        routineLogId: routineLogId ?? this.routineLogId,
        superSetId: superSetId ?? this.superSetId,
        exercise: exercise ?? this.exercise,
        notes: notes ?? this.notes,
        minReps: minReps ?? this.minReps,
        maxReps: maxReps ?? this.maxReps,
        sets: sets ?? this.sets,
        createdAt: createdAt ?? this.createdAt);
  }

  factory ExerciseLogDto.fromJson({String? routineLogId, DateTime? createdAt, required Map<String, dynamic> json}) {
    final superSetId = json["superSetId"] ?? "";
    final exerciseJson = json["exercise"];
    final exercise = ExerciseDto.fromJson(exerciseJson);
    final notes = json["notes"] ?? "";
    final minReps = json["minReps"] ?? 0;
    final maxReps = json["maxReps"] ?? 0;
    final setsInJsons = json["sets"] as List<dynamic>;
    List<SetDto> sets = [];
    if (setsInJsons.isNotEmpty && setsInJsons.first is String) {
      sets = setsInJsons.map((json) => SetDto.fromJson(jsonDecode(json), exerciseType: exercise.type)).toList();
    } else {
      sets = setsInJsons.map((json) => SetDto.fromJson(json, exerciseType: exercise.type)).toList();
    }
    return ExerciseLogDto(
        id: exercise.id,
        routineLogId: routineLogId,
        superSetId: superSetId,
        exercise: exercise,
        notes: notes,
        sets: sets,
        minReps: minReps,
        maxReps: maxReps,
        createdAt: createdAt ?? DateTime.now());
  }

  @override
  String toString() {
    return 'ExerciseLogDto{id: $id, routineLogId: $routineLogId, superSetId: $superSetId, exercise: $exercise, notes: $notes, minReps: $minReps, maxReps: $maxReps, sets: $sets, createdAt: $createdAt}';
  }
}

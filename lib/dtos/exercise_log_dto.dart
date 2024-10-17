import 'dart:convert';

import 'package:tracker_app/dtos/set_dto.dart';

import 'exercise_dto.dart';

class ExerciseLogDto {
  final String id;
  final String? routineLogId;
  final String superSetId;
  final ExerciseDto exercise;
  final List<ExerciseDto> substituteExercises;
  final String notes;
  final List<SetDto> sets;
  final DateTime createdAt;

  const ExerciseLogDto(this.id, this.routineLogId, this.superSetId, this.exercise, this.notes, this.sets,
      this.createdAt, this.substituteExercises);

  static Map<String, dynamic> toJson(ExerciseLogDto log) {
    final setJsons = log.sets.map((set) => set.toJson()).toList();
    final substituteExercisesJsons = log.substituteExercises.map((exercise) => ExerciseDto.toJson(exercise)).toList();

    return {
      "superSetId": log.superSetId,
      "exercise": ExerciseDto.toJson(log.exercise),
      "notes": log.notes,
      "sets": setJsons,
      "substituteExercises": substituteExercisesJsons
    };
  }

  ExerciseLogDto copyWith(
      {String? id,
      String? routineLogId,
      String? superSetId,
      String? exerciseId,
      ExerciseDto? exercise,
      String? notes,
      List<SetDto>? sets,
      DateTime? createdAt,
      List<ExerciseDto>? substituteExercises}) {
    return ExerciseLogDto(
        id ?? this.id,
        routineLogId ?? this.routineLogId,
        superSetId ?? this.superSetId,
        exercise ?? this.exercise,
        notes ?? this.notes,
        sets ?? this.sets,
        createdAt ?? this.createdAt,
        substituteExercises ?? this.substituteExercises);
  }

  factory ExerciseLogDto.fromJson({String? routineLogId, DateTime? createdAt, required Map<String, dynamic> json}) {
    final superSetId = json["superSetId"] ?? "";
    final exerciseJson = json["exercise"];
    final exercise = ExerciseDto.fromJson(exerciseJson);
    final notes = json["notes"] ?? "";
    final setsJsons = json["sets"] as List<dynamic>;
    final sets = setsJsons.map((json) => SetDto.fromJson(jsonDecode(json))).toList();
    final substituteExercisesJson = json["substituteExercises"] as List<dynamic>? ?? [];
    final substituteExercises = substituteExercisesJson.map((json) => ExerciseDto.fromJson(json)).toList();
    return ExerciseLogDto(
        exercise.id, routineLogId, superSetId, exercise, notes, sets, createdAt ?? DateTime.now(), substituteExercises);
  }

  @override
  String toString() {
    return 'ExerciseLogDto{id: $id, routineLogId: $routineLogId, superSetId: $superSetId, exercise: $exercise, notes: $notes, sets: $sets, createdAt: $createdAt}';
  }
}

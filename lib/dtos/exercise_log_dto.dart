import 'dart:convert';

import 'package:tracker_app/dtos/set_dto.dart';

import 'exercise_dto.dart';

class ExerciseLogDto {
  final String? routineLogId;
  final String superSetId;
  final ExerciseDTO exercise;
  final List<ExerciseDTO> substituteExercises;
  final String notes;
  final List<SetDto> sets;
  final DateTime createdAt;

  const ExerciseLogDto(
      {required this.routineLogId,
      required this.superSetId,
      required this.exercise,
      required this.notes,
      required this.sets,
      required this.createdAt,
      required this.substituteExercises});

  String toJson() {
    final setJsons = sets.map((set) => set.toJson()).toList();
    final substituteExercisesJsons = substituteExercises.map((exercise) => exercise.toJson()).toList();

    return jsonEncode({
      "superSetId": superSetId,
      "exercise": exercise.toJson(),
      "notes": notes,
      "sets": setJsons,
      "substituteExercises": substituteExercisesJsons
    });
  }

  ExerciseLogDto copyWith(
      {String? routineLogId,
      String? superSetId,
      String? exerciseId,
      ExerciseDTO? exercise,
      String? notes,
      List<SetDto>? sets,
      DateTime? createdAt,
      List<ExerciseDTO>? substituteExercises}) {
    return ExerciseLogDto(
        routineLogId: routineLogId ?? this.routineLogId,
        superSetId: superSetId ?? this.superSetId,
        exercise: exercise ?? this.exercise,
        notes: notes ?? this.notes,
        sets: sets ?? this.sets,
        createdAt: createdAt ?? this.createdAt,
        substituteExercises: substituteExercises ?? this.substituteExercises);
  }

  factory ExerciseLogDto.empty({required ExerciseDTO exercise}) {
    return ExerciseLogDto(routineLogId: "", superSetId: "", exercise: exercise, notes: "", sets: [], createdAt: DateTime.now(), substituteExercises: []);
  }

  factory ExerciseLogDto.fromJson({String? routineLogId, DateTime? createdAt, required Map<String, dynamic> json}) {
    final superSetId = json["superSetId"] ?? "";
    final exerciseJson = json["exercise"] as Map<String, dynamic>;
    final exercise = ExerciseDTO.fromJson(exerciseJson);
    final notes = json["notes"] ?? "";
    final setsJsons = json["sets"] as List<dynamic>;
    final sets = setsJsons.map((json) => SetDto.fromJson(jsonDecode(json))).toList();
    final substituteExercisesJson = json["substituteExercises"] as List<dynamic>? ?? [];
    final substituteExercises = substituteExercisesJson.map((json) => ExerciseDTO.fromJson(json)).toList();
    return ExerciseLogDto(
        routineLogId: routineLogId,
        superSetId: superSetId,
        exercise: exercise,
        notes: notes,
        sets: sets,
        createdAt: createdAt ?? DateTime.now(),
        substituteExercises: substituteExercises);
  }

  @override
  String toString() {
    return 'ExerciseLogDto{routineLogId: $routineLogId, superSetId: $superSetId, exercise: $exercise, notes: $notes, sets: $sets, createdAt: $createdAt}';
  }
}

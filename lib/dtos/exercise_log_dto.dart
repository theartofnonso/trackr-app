import 'dart:convert';

import 'package:tracker_app/dtos/set_dto.dart';

import 'exercise_dto.dart';
import 'exercise_variant_dto.dart';

class ExerciseLogDTO {
  final String? routineLogId;
  final String superSetId;
  final ExerciseVariantDTO exerciseVariant;
  final String notes;
  final List<SetDto> sets;
  final DateTime createdAt;

  const ExerciseLogDTO(
      {required this.routineLogId,
      required this.superSetId,
      required this.exerciseVariant,
      required this.notes,
      required this.sets,
      required this.createdAt});

  String toJson() {
    final setJsons = sets.map((set) => set.toJson()).toList();

    return jsonEncode({
      "superSetId": superSetId,
      "exercise": exerciseVariant.toJson(),
      "notes": notes,
      "sets": setJsons,
    });
  }

  ExerciseLogDTO copyWith(
      {String? routineLogId,
      String? superSetId,
      String? exerciseId,
      ExerciseVariantDTO? exerciseVariant,
      String? notes,
      List<SetDto>? sets,
      DateTime? createdAt}) {
    return ExerciseLogDTO(
        routineLogId: routineLogId ?? this.routineLogId,
        superSetId: superSetId ?? this.superSetId,
        exerciseVariant: exerciseVariant ?? this.exerciseVariant,
        notes: notes ?? this.notes,
        sets: sets ?? this.sets,
        createdAt: createdAt ?? this.createdAt);
  }

  factory ExerciseLogDTO.empty({required ExerciseDTO exercise}) {
    return ExerciseLogDTO(
        routineLogId: "", superSetId: "", exerciseVariant: exercise.defaultVariant(), notes: "", sets: [], createdAt: DateTime.now());
  }

  factory ExerciseLogDTO.fromJson({String? routineLogId, DateTime? createdAt, required Map<String, dynamic> json}) {
    final superSetId = json["superSetId"] ?? "";
    final exerciseJson = json["exercise"] as Map<String, dynamic>;
    final exercise = ExerciseVariantDTO.fromJson(exerciseJson);
    final notes = json["notes"] ?? "";
    final setsJsons = json["sets"] as List<dynamic>;
    final sets = setsJsons.map((json) => SetDto.fromJson(jsonDecode(json))).toList();

    return ExerciseLogDTO(
        routineLogId: routineLogId,
        superSetId: superSetId,
        exerciseVariant: exercise,
        notes: notes,
        sets: sets,
        createdAt: createdAt ?? DateTime.now());
  }

  @override
  String toString() {
    return 'ExerciseLogDto{routineLogId: $routineLogId, superSetId: $superSetId, exercise: $exerciseVariant, notes: $notes, sets: $sets, createdAt: $createdAt}';
  }
}

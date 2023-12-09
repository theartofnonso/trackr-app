import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/models/Exercise.dart';
import 'package:tracker_app/models/RoutineLog.dart';
import 'package:uuid/uuid.dart';

class ExerciseLogDto {
  final String id;
  final String routineLogId;
  final String superSetId;
  final Exercise exercise;
  final String notes;
  final List<SetDto> sets;
  final TemporalDateTime createdAt;

  ExerciseLogDto(this.id, this.routineLogId, this.superSetId, this.exercise, this.notes, this.sets, this.createdAt);

  ExerciseLogDto copyWith(
      {String? id, String? routineLogId, String? superSetId, String? exerciseId, Exercise? exercise, String? notes, List<SetDto>? sets, TemporalDateTime? createdAt}) {
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

  String toJson() {
    final setJons = sets.map((set) => (set).toJson()).toList();

    return jsonEncode({
      "superSetId": superSetId,
      "exercise": exercise,
      "notes": notes,
      "sets": setJons
    });
  }

  factory ExerciseLogDto.fromJson({RoutineLog? routineLog, required Map<String, dynamic> json}) {
    final routineLogId = routineLog?.id ?? "";
    final superSetId = json["superSetId"];
    final exerciseString = json["exercise"];
    final exercise = Exercise.fromJson(exerciseString);
    final notes = json["notes"];
    final setsJsons = json["sets"] as List<dynamic>;
    final sets = setsJsons.map((json) => SetDto.fromJson(jsonDecode(json))).toList();
    final createdAt = routineLog?.createdAt ?? TemporalDateTime.now();
    return ExerciseLogDto(const Uuid().v4(), routineLogId, superSetId, exercise, notes, sets, createdAt);
  }

  @override
  String toString() {
    return 'ProcedureDto{id: $id, routineLogId: $routineLogId, superSetId: $superSetId, exercise: $exercise, notes: $notes, sets: $sets, createdAt: $createdAt}';
  }
}
import 'dart:convert';
import 'package:tracker_app/dtos/routine_log_dto.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/models/ModelProvider.dart';
import 'package:uuid/uuid.dart';

class ExerciseLogDto {
  final String id;
  final RoutineLogDto? routineLog;
  final String superSetId;
  final Exercise exercise;
  final String notes;
  final List<SetDto> sets;
  final DateTime createdAt;

  const ExerciseLogDto(this.id, this.routineLog, this.superSetId, this.exercise, this.notes, this.sets, this.createdAt);

  ExerciseLogDto copyWith(
      {String? id,
      RoutineLogDto? routineLog,
      String? superSetId,
      String? exerciseId,
      Exercise? exercise,
      String? notes,
      List<SetDto>? sets,
      DateTime? createdAt}) {
    return ExerciseLogDto(
      id ?? this.id,
      routineLog ?? this.routineLog,
      superSetId ?? this.superSetId,
      exercise ?? this.exercise,
      notes ?? this.notes,
      sets ?? this.sets,
      createdAt ?? this.createdAt,
    );
  }

  String toJson() {
    final setJons = sets.map((set) => (set).toJson()).toList();

    return jsonEncode({"superSetId": superSetId, "exercise": exercise, "notes": notes, "sets": setJons});
  }

  factory ExerciseLogDto.fromJson({RoutineLogDto? routineLog, required Map<String, dynamic> json}) {
    final superSetId = json["superSetId"];
    final exerciseString = json["exercise"];
    final exercise = Exercise.fromJson(exerciseString);
    final notes = json["notes"];
    final setsJsons = json["sets"] as List<dynamic>;
    final sets = setsJsons.map((json) => SetDto.fromJson(jsonDecode(json))).toList();
    final createdAt = routineLog?.createdAt ?? DateTime.now();
    return ExerciseLogDto(const Uuid().v4(), routineLog, superSetId, exercise, notes, sets, createdAt);
  }

  @override
  String toString() {
    return 'ProcedureDto{id: $id, routineLogId: $routineLog, superSetId: $superSetId, exercise: $exercise, notes: $notes, sets: $sets, createdAt: $createdAt}';
  }
}

import 'dart:convert';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/models/Exercise.dart';
import 'package:uuid/uuid.dart';

class ProcedureDto {
  String id;
  final String superSetId;
  final Exercise exercise;
  final String notes;
  final List<SetDto> sets;

  ProcedureDto(this.id, this.superSetId, this.exercise, this.notes, this.sets);

  ProcedureDto copyWith(
      {String? id, String? superSetId, String? exerciseId, Exercise? exercise, String? notes, List<SetDto>? sets}) {
    return ProcedureDto(
      id ?? this.id,
      superSetId ?? this.superSetId,
      exercise ?? this.exercise,
      notes ?? this.notes,
      sets ?? this.sets,
    );
  }

  bool isEmpty() {
    return notes.isEmpty || sets.isEmpty;
  }

  bool isNotEmpty() {
    return notes.isNotEmpty || sets.isNotEmpty;
  }

  String toJson() {
    final setJons = sets.map((set) => (set).toJson()).toList();

    return jsonEncode({
      "superSetId": superSetId,
      "exercise": exercise,
      "notes": notes,
      "sets": setJons,
    });
  }

  factory ProcedureDto.fromJson(Map<String, dynamic> json) {
    final superSetId = json["superSetId"];
    final exerciseString = json["exercise"];
    final exercise = Exercise.fromJson(exerciseString);
    final notes = json["notes"];
    final setsJsons = json["sets"] as List<dynamic>;
    final sets = setsJsons.map((json) => SetDto.fromJson(jsonDecode(json))).toList();
    return ProcedureDto(const Uuid().v4(), superSetId, exercise, notes, sets);
  }

  @override
  String toString() {
    return 'ProcedureDto{id: $id, superSetId: $superSetId, exercise: $exercise, notes: $notes, sets: $sets}';
  }
}

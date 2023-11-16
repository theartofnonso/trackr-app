import 'dart:convert';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/models/Exercise.dart';

class ProcedureDto {
  final String superSetId;
  final Exercise exercise;
  final String notes;
  final List<SetDto> sets;

  ProcedureDto({this.superSetId = "", required this.exercise, this.notes = "", this.sets = const [],});

  ProcedureDto copyWith(
      {String? superSetId,
      String? exerciseId,
      Exercise? exercise,
      String? notes,
      List<SetDto>? sets}) {
    return ProcedureDto(
        superSetId: superSetId ?? this.superSetId,
        exercise: exercise ?? this.exercise,
        notes: notes ?? this.notes,
        sets: sets ?? this.sets,);
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
    return ProcedureDto(
        superSetId: superSetId,
        notes: notes,
        sets: sets,
        exercise: exercise);
  }

  @override
  String toString() {
    return 'ProcedureDto{superSetId: $superSetId, exercise: $exercise, notes: $notes, sets: $sets}';
  }
}

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/set_dto.dart';

import '../models/Exercise.dart';
import '../providers/exercises_provider.dart';

class ProcedureDto {
  final String superSetId;
  final Exercise exercise;
  final String notes;
  final List<SetDto> sets;
  final Duration restInterval;

  ProcedureDto({this.superSetId = "",
    required this.exercise,
    this.notes = "",
    this.sets = const [],
    this.restInterval = Duration.zero});

  ProcedureDto copyWith({String? superSetId,
    Exercise? exercise,
    String? notes,
    List<SetDto>? sets,
    Duration? restInterval}) {
    return ProcedureDto(
        superSetId: superSetId ?? this.superSetId,
        exercise: exercise ?? this.exercise,
        notes: notes ?? this.notes,
        sets: sets ?? this.sets,
        restInterval: restInterval ?? this.restInterval);
  }

  bool isEmpty() {
    return notes.isEmpty || sets.isEmpty || restInterval == Duration.zero;
  }

  bool isNotEmpty() {
    return notes.isNotEmpty || sets.isNotEmpty || restInterval != Duration.zero;
  }

  String toJson() {
    return jsonEncode({
      "superSetId": superSetId,
      "exercise": exercise.id,
      "notes": notes,
      "sets": sets.map((set) => set.toJson()).toList(),
      "restInterval": restInterval.inMilliseconds
    });
  }

  factory ProcedureDto.fromJson(Map<String, dynamic> json, BuildContext context) {
    final superSetId = json["superSetId"];
    final exerciseId = json["exercise"];
    print(exerciseId);
    final exercise = Provider.of<ExerciseProvider>(context, listen: false).whereExercise(exerciseId: exerciseId);
    final notes = json["notes"];
    final setsJsons = json["sets"] as List<dynamic>;
    final sets = setsJsons.map((json) => SetDto.fromJson(jsonDecode(json))).toList();
    final restInterval = json["restInterval"];
    return ProcedureDto(superSetId: superSetId, notes: notes, sets: sets, restInterval: Duration(milliseconds: restInterval), exercise: exercise);
  }


  @override
  String toString() {
    return 'ProcedureDto{superSetId: $superSetId, exercise: $exercise, notes: $notes, sets: $sets}';
  }
}

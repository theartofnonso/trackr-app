import 'dart:convert';
import 'package:tracker_app/dtos/duration_num_pair.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/dtos/double_num_pair.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/models/Exercise.dart';

class ProcedureDto {
  final String superSetId;
  final Exercise exercise;
  final String notes;
  final List<SetDto> sets;
  final Duration restInterval;

  ProcedureDto(
      {this.superSetId = "",
      required this.exercise,
      this.notes = "",
      this.sets = const [],
      this.restInterval = Duration.zero});

  ProcedureDto copyWith(
      {String? superSetId,
      String? exerciseId,
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
    final exerciseType = ExerciseType.fromString(exercise.type);
    final setJons = switch (exerciseType) {
      ExerciseType.weightAndReps ||
      ExerciseType.weightedBodyWeight ||
      ExerciseType.assistedBodyWeight ||
      ExerciseType.bodyWeightAndReps ||
      ExerciseType.weightAndDistance =>
        sets.map((set) => (set as DoubleNumPair).toJson()).toList(),
      ExerciseType.duration ||
      ExerciseType.distanceAndDuration =>
        sets.map((set) => (set as DurationNumPair).toJson()).toList(),
    };

    return jsonEncode({
      "superSetId": superSetId,
      "exercise": exercise,
      "notes": notes,
      "sets": setJons,
      "restInterval": restInterval.inMilliseconds
    });
  }

  factory ProcedureDto.fromJson(Map<String, dynamic> json) {
    final superSetId = json["superSetId"];
    final exerciseString = json["exercise"];
    final exercise = Exercise.fromJson(exerciseString);
    final exerciseType = ExerciseType.fromString(exercise.type);
    final notes = json["notes"];
    final setsJsons = json["sets"] as List<dynamic>;
    final sets = switch (exerciseType) {
      ExerciseType.weightAndReps ||
      ExerciseType.weightedBodyWeight ||
      ExerciseType.assistedBodyWeight ||
      ExerciseType.bodyWeightAndReps ||
      ExerciseType.weightAndDistance =>
        setsJsons.map((json) => DoubleNumPair.fromJson(jsonDecode(json))).toList(),
      ExerciseType.duration ||
      ExerciseType.distanceAndDuration =>
        setsJsons.map((json) => DurationNumPair.fromJson(jsonDecode(json))).toList()
    };
    final restInterval = json["restInterval"];
    return ProcedureDto(
        superSetId: superSetId,
        notes: notes,
        sets: sets,
        restInterval: Duration(milliseconds: restInterval),
        exercise: exercise);
  }

  @override
  String toString() {
    return 'ProcedureDto{superSetId: $superSetId, exercise: $exercise, notes: $notes, sets: $sets}, restInterval: $restInterval';
  }
}

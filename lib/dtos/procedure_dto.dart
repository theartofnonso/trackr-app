import 'package:tracker_app/dtos/set_dto.dart';

import 'exercise_dto.dart';

class ProcedureDto {
  final String superSetId;
  final ExerciseDto exercise;
  final String notes;
  final List<SetDto> sets;
  final bool isSuperSet;
  final Duration restInterval;

  ProcedureDto(
      {this.superSetId = "",
      required this.exercise,
      this.notes = "",
      this.sets = const [],
      this.isSuperSet = false,
      this.restInterval = Duration.zero});

  ProcedureDto copyWith(
      {String? superSetId,
      ExerciseDto? exercise,
      String? notes,
      List<SetDto>? sets,
      bool? isSuperSet,
      Duration? restInterval}) {
    return ProcedureDto(
        superSetId: superSetId ?? this.superSetId,
        exercise: exercise ?? this.exercise,
        notes: notes ?? this.notes,
        sets: sets ?? this.sets,
        isSuperSet: isSuperSet ?? this.isSuperSet,
        restInterval: restInterval ?? this.restInterval);
  }

  bool isEmpty() {
    return notes.isEmpty || sets.isEmpty || !isSuperSet || restInterval == Duration.zero;
  }

  bool isNotEmpty() {
    return notes.isNotEmpty || sets.isNotEmpty || isSuperSet || restInterval != Duration.zero;
  }

  @override
  String toString() {
    return 'ProcedureDto{superSetId: $superSetId, exercise: $exercise, notes: $notes, sets: $sets, isSuperSet: $isSuperSet}';
  }
}

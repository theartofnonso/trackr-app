
import 'package:tracker_app/dtos/procedure_dto.dart';

import 'exercise_dto.dart';

class ExerciseInWorkoutDto {

  String superSetId;
  final ExerciseDto exercise;
  String notes;
  List<ProcedureDto> procedures = [];
  bool isSuperSet;
  Duration? procedureDuration;

  ExerciseInWorkoutDto({this.superSetId = "", this.notes = "", required this.exercise, this.isSuperSet = false});

  @override
  String toString() {
    return 'ExerciseInWorkoutDto{superSetId: $superSetId, exercise: $exercise, notes: $notes, procedures: $procedures, isSuperSet: $isSuperSet}';
  }
}

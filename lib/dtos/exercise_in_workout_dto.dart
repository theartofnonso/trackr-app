
import 'package:tracker_app/dtos/procedure_dto.dart';

import 'exercise_dto.dart';

class ExerciseInWorkoutDto {

  String superSetId;
  final ExerciseDto exercise;
  String notes;
  List<ProcedureDto> warmupProcedures = [];
  List<ProcedureDto> workingProcedures = [];
  bool isSuperSet;
  Duration? warmUpProcedureDuration;
  Duration? workingProcedureDuration;

  ExerciseInWorkoutDto({this.superSetId = "", this.notes = "", required this.exercise, this.isSuperSet = false});

  @override
  String toString() {
    return 'ExerciseInWorkoutDto{superSetId: $superSetId, exercise: $exercise, notes: $notes, warmupProcedures: $warmupProcedures, workingProcedures: $workingProcedures, isSuperSet: $isSuperSet}';
  }
}

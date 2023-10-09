
import 'package:tracker_app/dtos/procedure_dto.dart';

import 'exercise_dto.dart';

class ExerciseInWorkoutDto {
  String superSetId;
  final ExerciseDto exercise;
  List<ProcedureDto> warmupProcedures;
  List<ProcedureDto> workingProcedures;
  bool isSuperSet;

  ExerciseInWorkoutDto({this.superSetId = "", required this.exercise, this.warmupProcedures = const <ProcedureDto>[], this.workingProcedures = const <ProcedureDto>[], this.isSuperSet = false});
}

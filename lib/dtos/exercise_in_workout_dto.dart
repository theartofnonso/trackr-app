
import 'package:tracker_app/dtos/procedure_dto.dart';

import 'exercise_dto.dart';

class ExerciseInWorkoutDto {
  String superSetId;
  final ExerciseDto exercise;
  final List<ProcedureDto> procedures;
  bool isSuperSet;

  ExerciseInWorkoutDto({this.superSetId = "", required this.exercise, required this.procedures, this.isSuperSet = false});
}

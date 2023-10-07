
import 'package:tracker_app/dtos/procedure_dto.dart';

import 'exercise_dto.dart';

class ExerciseInWorkoutDto {
  final ExerciseDto exercise;
  final List<ProcedureDto> procedures;

  ExerciseInWorkoutDto({required this.exercise, required this.procedures});
}

import 'package:tracker_app/dtos/exercise_in_workout_dto.dart';

class WorkoutDto {
  final String name;
  final List<ExerciseInWorkoutDto> exercises;
  final String? notes;
  final Duration? repsInterval;
  final Duration? setsInterval;

  WorkoutDto({required this.name, required this.exercises, this.notes, this.repsInterval, this.setsInterval});
}
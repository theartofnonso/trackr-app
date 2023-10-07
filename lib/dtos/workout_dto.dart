import 'package:tracker_app/dtos/exercise_in_workout_dto.dart';

class Workout {
  final String name;
  final List<ExerciseInWorkoutDto> exercises;
  final String? notes;
  final Duration? repsInterval;
  final Duration? setsInterval;

  Workout(this.name, this.exercises, this.notes, this.repsInterval, this.setsInterval);
}
import '../../dtos/exercise_dto.dart';

enum ExerciseMetric implements ExerciseConfig {
  weights("Weights", "Log the weight and reps for strength exercises like bench press or squats curls."),
  reps("Reps", "Track the number of reps for bodyweight exercises like pull-ups, crunches, or burpees"),
  duration("Duration", "Record how long you hold or perform time-based exercises like planks or Dead Hang.");

  const ExerciseMetric(this.name, this.description);

  @override
  final String name;

  @override
  final String description;

  static ExerciseMetric fromString(String string) {
    return values
        .firstWhere((value) => value.name.toLowerCase() == string.toLowerCase());
  }

}

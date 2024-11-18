enum ExerciseMetric {
  weights("Weights", "With Weights", "Log the weight and reps for strength exercises like bench press or squats curls."),
  reps("Reps", "Without Weights", "Track the number of reps for bodyweight exercises like pull-ups, crunches, or burpees"),
  duration("Duration", "Time", "Record how long you hold or perform time-based exercises like planks or Dead Hang.");

  const ExerciseMetric(this.name, this.friendlyName, this.description);

  final String name;
  final String friendlyName;
  final String description;

  static ExerciseMetric fromString(String string) {
    return values
        .firstWhere((value) => value.name.toLowerCase() == string.toLowerCase());
  }
}

enum ExerciseMetric {
  weights("Weights", "Bench Press, Dumbbell Curls"),
  reps("Reps", "Pull Ups, Crunches, Burpees"),
  duration("Duration", "Planks, Yoga"),
  none("None", "");

  const ExerciseMetric(this.name, this.description);

  final String name;
  final String description;

  static ExerciseMetric fromString(String string) {
    return ExerciseMetric.values
        .firstWhere((value) => value.name.toLowerCase() == string.toLowerCase(), orElse: () => none);
  }
}

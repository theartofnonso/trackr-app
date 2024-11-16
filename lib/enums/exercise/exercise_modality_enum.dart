enum ExerciseModality {
  unilateral("Unilateral", "Perform exercises one side at a time, like single-leg deadlifts or single-arm rows.”"),
  bilateral("Bilateral", "Engage both sides together, such as squats or bench presses."),
  none("none", "");

  const ExerciseModality(this.name, this.description);

  final String name;
  final String description;

  static ExerciseModality fromString(String string) {
    return values.firstWhere((value) => value.name.toLowerCase() == string.toLowerCase(), orElse: () => none);
  }
}

enum ExerciseModality {
  unilateral("unilateral"),
  bilateral("bilateral"),
  none("none");

  const ExerciseModality(this.name);

  final String name;

  static ExerciseModality fromString(String string) {
    return ExerciseModality.values.firstWhere((value) => value.name.toLowerCase() == string.toLowerCase(), orElse: () => none);
  }
}

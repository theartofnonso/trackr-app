enum ExerciseStance {
  seated("Seated", "Perform exercises while seated, focusing on stability and controlled movement."),
  standing("Standing", "Engage your core and balance with exercises done while standing upright."),
  lying("Lying", "Target muscles effectively with exercises performed while lying down.");

  const ExerciseStance(this.name, this.description);

  final String name;
  final String description;

  static ExerciseStance fromString(String string) {
    return values.firstWhere((value) => value.name.toLowerCase() == string.toLowerCase(), orElse: () => standing);
  }
}

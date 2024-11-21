enum ExerciseStance {
  seated("Seated", "Perform exercises while seated, focusing on stability and controlled movement."),
  standing("Standing", "Engage your core and balance with exercises done while standing upright."),
  kneeling("Kneeling", "A stance where the body is supported on the knees."),
  hanging("Hanging", "A stance where the body is suspended from a fixed bar or support, engaging the upper body and core to maintain stability."),
  lying("Lying", "Target muscles effectively with exercises performed while lying down.");

  const ExerciseStance(this.name, this.description);

  final String name;
  final String description;

  static ExerciseStance fromString(String string) {
    return values.firstWhere((value) => value.toString().toLowerCase() == string.toLowerCase(), orElse: () => standing);
  }
}

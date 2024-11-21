enum ExercisePosition {
  incline("Incline", "Performed at an upward angle to target the upper portion of muscles, like the upper chest."),
  decline("Decline", "Performed at a downward angle to focus on the lower portion of muscles, like the lower chest."),
  neutral("Neutral", "Performed in a flat position for balanced muscle engagement, like standard bench press.");

  const ExercisePosition(this.name, this.description);

  final String name;
  final String description;

  static ExercisePosition fromString(String string) {
    return values.firstWhere((value) => value.toString().toLowerCase() == string.toLowerCase(), orElse: () => neutral);
  }
}

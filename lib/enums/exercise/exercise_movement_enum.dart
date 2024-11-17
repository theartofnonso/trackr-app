enum ExerciseMovement {
  overhead("Overhead",
      "Overhead movements involve lifting or extending weights above your head, focusing on muscles like triceps, shoulders, and back."),
  internalRotation("Internal Rotation",
      "A movement pattern where the limb rotates towards the midline of the body."),
  externalRotation("External Rotation",
      "A movement pattern where the limb rotates away from the midline of the body."),
  lateral("Lateral",
      "Lateral movements work the sides of your body, engaging muscles like deltoids and obliques to improve balance and coordination."),
  front("Front",
      "Front movements involve pushing or pulling weights directly in front of your body, targeting muscles like chest, shoulders, and arms."),
  reverse("Reverse",
      "Reverse movements engage muscles on the back of your body, such as rear delts, traps, and lats, to improve posture and pulling strength."),
  highToLow("High to low", "A movement pattern where the resistance starts above shoulder level and is brought downwards, targeting muscles with a downward force trajectory."),
  lowToHigh("Low to high", "A movement pattern where the resistance starts below shoulder level and is lifted upwards, engaging muscles with an upward force trajectory."),
  none("N/a", "");

  const ExerciseMovement(this.name, this.description);

  final String name;
  final String description;

  static ExerciseMovement fromString(String string) {
    return values.firstWhere((value) => value.name.toLowerCase() == string.toLowerCase(), orElse: () => none);
  }
}

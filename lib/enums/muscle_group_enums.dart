enum MuscleGroup {
  abs("Abs", "Abdominal muscles are essential for core stability, balance, and supporting almost all compound lifts."),
  abductors("Abductors",
      "Abductors are responsible for moving the legs away from the body's midline, essential for lateral movements."),
  adductors("Adductors",
      "Adductors bring the legs toward the midline of the body and support stability in squats and lunges."),
  biceps("Biceps", "Biceps are responsible for elbow flexion, assisting in pulling movements and lifting."),
  back("Back", "The back muscles support posture, pulling movements, and core stability."),
  calves(
      "Calves", "Calves enable ankle flexion, essential for running, jumping, and stability in lower-body movements."),
  chest("Chest",
      "The chest muscles are key for pushing movements, including presses and push-ups, and contribute to upper body strength."),
  glutes("Glutes",
      "Glutes are powerful muscles for hip extension, playing a key role in squats, deadlifts, and explosive movements."),
  hamstrings("Hamstrings",
      "Hamstrings are responsible for knee flexion and hip extension, aiding in running, jumping, and lower-body lifts."),
  shoulders("Shoulders", "Shoulders (deltoids) enable arm rotation and are involved in pushing and lifting movements."),
  triceps("Triceps",
      "Triceps are the primary muscles for elbow extension, playing a key role in pushing movements."),
  quadriceps("Quadriceps", "Quadriceps are key for knee extension, vital for squats, lunges, and running.");
  // Properties
  final String name;
  final String description;

  // Constructor
  const MuscleGroup(this.name, this.description);

  // Methods

  // Get all MuscleGroup values sorted alphabetically
  static List<MuscleGroup> get valuesSorted => MuscleGroup.values.toList()..sort((a, b) => a.name.compareTo(b.name));

  String toJson() => name;

  // Find a MuscleGroup by its name (case insensitive)
  static MuscleGroup fromJson(String string) {
    return MuscleGroup.values.firstWhere(
      (group) => group.name.toLowerCase() == string.toLowerCase(),
    );
  }
}

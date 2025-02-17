enum TrainingGoal {
  hypertrophy(
    displayName: "Hypertrophy (Muscle Growth)",
    description: "Build muscle size through progressive overload and higher-volume training.",
    minReps: 6,
    maxReps: 12,
  ),
  endurance(
    displayName: "Muscular Endurance",
    description: "Enhance muscle resistance to fatigue, allowing you to perform longer and more efficiently in physical activities.",
    minReps: 12,
    maxReps: 20,
  ),
  strength(
    displayName: "Strength",
    description: "Maximize your power by lifting heavier weights and pushing your muscles to new limits.",
    minReps: 1,
    maxReps: 6,
  );

  const TrainingGoal({
    required this.displayName,
    required this.description,
    required this.minReps,
    required this.maxReps
  });

  final String displayName;
  final String description;
  final int minReps;
  final int maxReps;

  static TrainingGoal fromString(String string) {
    return TrainingGoal.values.firstWhere((value) => value.name.toLowerCase() == string.toLowerCase(), orElse: () => hypertrophy);
  }
}

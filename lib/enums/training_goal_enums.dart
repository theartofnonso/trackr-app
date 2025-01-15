enum TrainingGoal {
  hypertrophy(
    displayName: "Hypertrophy (Muscle Growth)",
    description: "Build muscle size through progressive overload and higher-volume training.",
  ),
  endurance(
    displayName: "Endurance",
    description: "Boost stamina, improve cardiovascular health, and push your limits so you can keep going for longer periods of time.",
  ),
  strength(
    displayName: "Strength",
    description: "Maximize your power by lifting heavier weights and pushing your muscles to new limits.",
  );

  const TrainingGoal({
    required this.displayName,
    required this.description,
  });

  final String displayName;
  final String description;

  static TrainingGoal fromString(String string) {
    return TrainingGoal.values.firstWhere((value) => value.name.toLowerCase() == string.toLowerCase(), orElse: () => hypertrophy);
  }
}

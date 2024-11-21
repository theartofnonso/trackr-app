enum ExerciseConfigurationKey {
  setType(displayName: "Set Type"),
  equipment(displayName: "Equipment");

  final String displayName;

  const ExerciseConfigurationKey({required this.displayName});
}
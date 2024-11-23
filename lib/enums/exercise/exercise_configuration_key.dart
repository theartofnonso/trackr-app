enum ExerciseConfigurationKey {
  setType(displayName: "Set Type"),
  equipment(displayName: "Equipment"),
  lowerBodyModality(displayName: "Modes"),
  upperBodyModality(displayName: "Modes"),
  stance(displayName: "Stance"),
  movement(displayName: "Body Movement"),
  seatingPosition(displayName: "Seating Position"),
  layingPosition(displayName: "Laying Position"),
  standingPosition(displayName: "Standing Position");

  final String displayName;

  const ExerciseConfigurationKey({required this.displayName});

  static ExerciseConfigurationKey _fromString(String string) {
    return values.firstWhere((value) => value.name.toLowerCase() == string.toLowerCase());
  }

  static ExerciseConfigurationKey fromJson(String string) {
    return ExerciseConfigurationKey._fromString(string);
  }

  String toJson() => name;
}
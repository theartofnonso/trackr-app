enum MuscleGroupFamily {
  legs("Legs"),
  back("Back"),
  arms("Arms"),
  chest("Chest"),
  shoulders("Shoulders"),
  core("Core"),
  neck("Neck"),
  fullBody("Full Body"),
  cardio("Cardio");

  const MuscleGroupFamily(this.name);

  final String name;

}

enum MuscleGroup {
  forearms("Forearms", MuscleGroupFamily.arms),
  biceps("Biceps", MuscleGroupFamily.arms),
  triceps("Triceps", MuscleGroupFamily.arms),
  back("Back", MuscleGroupFamily.back),
  lats("Lats", MuscleGroupFamily.back),
  traps("Traps", MuscleGroupFamily.back),
  abs("Abs", MuscleGroupFamily.core),
  chest("Chest", MuscleGroupFamily.chest),
  shoulders("Shoulders", MuscleGroupFamily.shoulders),
  abductors("Abductors", MuscleGroupFamily.legs),
  adductors("Adductors", MuscleGroupFamily.legs),
  glutes("Glutes", MuscleGroupFamily.legs),
  hamstrings("Hamstrings", MuscleGroupFamily.legs),
  quadriceps("Quadriceps", MuscleGroupFamily.legs),
  calves("Calves", MuscleGroupFamily.legs),
  neck("Neck", MuscleGroupFamily.neck),
  cardio("Cardio", MuscleGroupFamily.cardio),
  fullBody("Full Body", MuscleGroupFamily.fullBody),
  legs("Legs", MuscleGroupFamily.legs);

  const MuscleGroup(this.name, this.family);

  final String name;
  final MuscleGroupFamily family;

  static MuscleGroup fromString(String string) {
    return MuscleGroup.values.firstWhere((value) => value.name == string);
  }
}
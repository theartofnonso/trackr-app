enum MuscleGroupFamily {
  core("Core"),
  legs("Legs"),
  back("Back"),
  arms("Arms"),
  chest("Chest"),
  neck("Neck"),
  shoulders("Shoulders");

  const MuscleGroupFamily(this.name);

  final String name;
}

enum MuscleGroup {
  forearm("Forearm", MuscleGroupFamily.arms),
  biceps("Biceps", MuscleGroupFamily.arms),
  triceps("Triceps", MuscleGroupFamily.arms),
  backLower("Lower Back", MuscleGroupFamily.back),
  back("Back", MuscleGroupFamily.back),
  lats("Lats", MuscleGroupFamily.back),
  traps("Traps", MuscleGroupFamily.back),
  abs("Abs", MuscleGroupFamily.core),
  fullBody("Full Body", MuscleGroupFamily.core),
  chestUpper("Upper Chest", MuscleGroupFamily.chest),
  chest("Chest", MuscleGroupFamily.chest),
  chestInner("Inner Chest", MuscleGroupFamily.chest),
  abductors("Abductors", MuscleGroupFamily.legs),
  adductors("Adductors", MuscleGroupFamily.legs),
  glutes("Glutes", MuscleGroupFamily.legs),
  hamstrings("Hamstrings", MuscleGroupFamily.legs),
  quadriceps("Quadriceps", MuscleGroupFamily.legs),
  calves("Calves", MuscleGroupFamily.legs),
  shoulder("Shoulder", MuscleGroupFamily.shoulders),
  shoulderFrontal("Shoulder Frontal", MuscleGroupFamily.shoulders),
  shoulderSide("Shoulder Side", MuscleGroupFamily.shoulders),
  shoulderRear("Shoulder Rear", MuscleGroupFamily.shoulders),
  backUpper("Upper Back", MuscleGroupFamily.shoulders),
  neck("Neck", MuscleGroupFamily.neck);
  
  const MuscleGroup(this.name, this.family);

  final String name;
  final MuscleGroupFamily family;

  static MuscleGroup fromString(String string) {
    return MuscleGroup.values.firstWhere((value) => value.name == string);
  }
}
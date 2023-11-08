enum MuscleGroup {
  abs("Abs"),
  abductors("Abductors"),
  adductors("Adductors"),
  back("Back"),
  biceps("Biceps"),
  calves("Calves"),
  chest("Chest"),
  forearm("Forearm"),
  glutes("Glutes"),
  hamstrings("Hamstrings"),
  chestInner("Inner Chest"),
  lats("Lats"),
  backLower("Lower Back"),
  chestLower("Lower Chest"),
  neck("Neck"),
  quadriceps("Quadriceps"),
  shoulder("Shoulder"),
  shoulderFrontal("Shoulder Frontal"),
  shoulderSide("Shoulder Side"),
  shoulderRear("Shoulder Rear"),
  traps("Traps"),
  triceps("Triceps"),
  backUpper("Upper Back"),
  chestUpper("Upper Chest");

  const MuscleGroup(this.name);

  final String name;

  static MuscleGroup fromString(String string) {
    return MuscleGroup.values.firstWhere((value) => value.name == string);
  }
}
enum MuscleGroup {
  abs("Abs"),
  adductors("Adductors"),
  abductors("Abductors"),
  back("Back"),
  backUpper("Upper Back"),
  backLower("Lower Back"),
  lats("Lats"),
  traps("Traps"),
  biceps("Biceps"),
  chest("Chest"),
  chestUpper("Upper Chest"),
  chestInner("Inner Chest"),
  chestLower("Lower Chest"),
  shoulder("Shoulder"),
  shoulderFrontal("Shoulder Frontal"),
  shoulderSide("Shoulder Side"),
  shoulderRear("Shoulder Rear"),
  neck("Neck"),
  triceps("Triceps"),
  forearm("Forearm"),
  quadriceps("Quadriceps"),
  hamstrings("Hamstrings"),
  glutes("Glutes"),
  calves("Calves");

  const MuscleGroup(this.name);

  final String name;

  static MuscleGroup fromString(String string) {
    return MuscleGroup.values.firstWhere((value) => value.name == string);
  }
}
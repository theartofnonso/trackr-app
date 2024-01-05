enum ExerciseType {
  weightAndReps("WR", "Weight & Reps", "Bench Press, Dumbbell Curls"),
  bodyWeight("BW", "Bodyweight", "Pull Ups, Crunches, Burpees"),
  weightedBodyWeight("WBW", "Weight On Bodyweight", "Weighted Pull Ups, Weighted Dips"),
  assistedBodyWeight("ABW", "Assisted Bodyweight", "Assisted Pull Ups, Assisted Dips"),
  duration("DR", "Duration", "Planks, Yoga");

  const ExerciseType(this.id, this.name, this.description);

  final String id;
  final String name;
  final String description;

  static ExerciseType fromString(String string) {
    return ExerciseType.values.firstWhere((value) => value.name == string || value.id == string);
  }
}
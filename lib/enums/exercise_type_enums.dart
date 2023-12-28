enum ExerciseType {
  weightAndReps("Weight And Reps", "Bench Press, Dumbbell Curls"),
  bodyWeightAndReps("Bodyweight", "Pull Ups, Crunches, Burpees"),
  weightedBodyWeight("Weighted Bodyweight", "Weighted Pull Ups, Weighted Dips"),
  assistedBodyWeight("Assisted Bodyweight", "Assisted Pull Ups, Assisted Dips"),
  duration("Duration", "Planks, Yoga"),
  durationAndDistance("Distance And Duration", "Running, Cycling"),
  weightAndDistance("Weight And Distance", "Farmers walk");

  const ExerciseType(this.name, this.description);

  final String name;
  final String description;

  static ExerciseType fromString(String string) {
    return ExerciseType.values.firstWhere((value) => value.name == string);
  }
}
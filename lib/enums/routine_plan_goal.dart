enum RoutinePlanGoal {
  muscle(description: "Build Muscle"),
  fat(description: "Lose Fat"),
  fitness(description: "Be Fit");

  final String description;

  const RoutinePlanGoal({required this.description});
}
enum TrainingParameters {
  strength(
    minReps: 1,
    maxReps: 5,
    minRpe: 8.0,
    maxRpe: 9.5,
    minPercentage: 0.8,
    maxPercentage: 0.9,
  ),
  hypertrophy(
    minReps: 6,
    maxReps: 12,
    minRpe: 7.0,
    maxRpe: 8.5,
    minPercentage: 0.65,
    maxPercentage: 0.8,
  ),
  endurance(
    minReps: 12,
    maxReps: 20,
    minRpe: 6.0,
    maxRpe: 7.5,
    minPercentage: 0.5,
    maxPercentage: 0.65,
  );

  final int minReps;
  final int maxReps;
  final double minRpe;
  final double maxRpe;
  final double minPercentage;
  final double maxPercentage;

  const TrainingParameters({
    required this.minReps,
    required this.maxReps,
    required this.minRpe,
    required this.maxRpe,
    required this.minPercentage,
    required this.maxPercentage,
  });
}

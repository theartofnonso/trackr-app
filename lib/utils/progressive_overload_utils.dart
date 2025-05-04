enum TrainingProgression { increase, decrease, maintain }

class TrainingData {
  final int reps;
  final int rpe;
  final double weight;

  TrainingData({
    required this.reps,
    required this.rpe,
    required this.weight,
  });

  @override
  String toString() {
    return 'TrainingData{reps: $reps, rpe: $rpe, weight: $weight}';
  }


}

TrainingProgression getTrainingProgression({
  required List<TrainingData> data,
  required int targetMinReps,
  required int targetMaxReps,
}) {
  if (data.isEmpty) return TrainingProgression.maintain;

  final currentWeight = data.last.weight;
  final currentWeightSessions = data
      .where((session) => session.weight == currentWeight)
      .toList();

  if (currentWeightSessions.isEmpty) return TrainingProgression.maintain;

  int increaseCount = 0;
  int decreaseCount = 0;
  int maintainCount = 0;

  for (final session in currentWeightSessions) {
    final suggestion = _getSessionSuggestion(
      session: session,
      targetMin: targetMinReps,
      targetMax: targetMaxReps,
    );

    switch (suggestion) {
      case TrainingProgression.increase:
        increaseCount++;
        break;
      case TrainingProgression.decrease:
        decreaseCount++;
        break;
      case TrainingProgression.maintain:
        maintainCount++;
        break;
    }
  }

  return _determineOverallProgression(
    increaseCount: increaseCount,
    decreaseCount: decreaseCount,
    maintainCount: maintainCount,
  );
}

TrainingProgression _getSessionSuggestion({
  required TrainingData session,
  required int targetMin,
  required int targetMax,
}) {
  const int rpeIncreaseThreshold = 7;

  if (session.reps >= targetMax) {
    return session.rpe <= rpeIncreaseThreshold
        ? TrainingProgression.increase
        : TrainingProgression.maintain;
  }

  if (session.reps < targetMin) {
    return TrainingProgression.decrease;
  }

  return TrainingProgression.maintain;
}

TrainingProgression _determineOverallProgression({
  required int increaseCount,
  required int decreaseCount,
  required int maintainCount,
}) {
  if (increaseCount > decreaseCount && increaseCount > maintainCount) {
    return TrainingProgression.increase;
  }
  if (decreaseCount > increaseCount && decreaseCount > maintainCount) {
    return TrainingProgression.decrease;
  }
  return TrainingProgression.maintain;
}
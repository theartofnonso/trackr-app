enum TrainingProgression { increase, decrease, maintain }

enum WeightProgression { increase, decrease, maintain }

class TrainingEffort {
  final double weight;
  final int reps;
  final int rpe;

  TrainingEffort({required this.weight, required this.reps, required this.rpe});
}

WeightProgression getWeightProgression(List<TrainingEffort> effort, int targetMinReps, int targetMaxReps) {
  if (effort.isEmpty) return WeightProgression.maintain; // Handle empty input

  int increaseCount = 0;
  int decreaseCount = 0;
  int maintainCount = 0;

  for (final session in effort) {
    final suggestion = _getTrainingProgression(session, targetMinReps, targetMaxReps);
    switch(suggestion) {

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

  if (increaseCount > decreaseCount && increaseCount > maintainCount) {
    return WeightProgression.increase;
  } else if (decreaseCount > increaseCount && decreaseCount > maintainCount) {
    return WeightProgression.decrease;
  }
  return WeightProgression.maintain;
}

TrainingProgression _getTrainingProgression(TrainingEffort session, int targetMin, int targetMax) {
  final reps = session.reps;
  final rpe = session.rpe;

  if (reps > targetMax) {
    return TrainingProgression.increase;
  } else if (reps < targetMin) {
    return rpe >= 8 ? TrainingProgression.decrease : TrainingProgression.maintain;
  } else {
    final midPoint = (targetMin + targetMax) / 2;
    if (reps >= midPoint) {
      return rpe <= 6 ? TrainingProgression.increase : TrainingProgression.maintain;
    } else {
      return rpe >= 8 ? TrainingProgression.decrease : TrainingProgression.maintain;
    }
  }
}
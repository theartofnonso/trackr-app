enum TrainingProgression { increase, decrease, maintain }

class TrainingData {
  final int reps;
  final int rpe;

  TrainingData({required this.reps, required this.rpe});
}

TrainingProgression getTrainingProgression(List<TrainingData> data, int targetMinReps, int targetMaxReps) {
  if (data.isEmpty) return TrainingProgression.maintain; // Handle empty input

  int increaseCount = 0;
  int decreaseCount = 0;
  int maintainCount = 0;

  for (final session in data) {
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
    return TrainingProgression.increase;
  } else if (decreaseCount > increaseCount && decreaseCount > maintainCount) {
    return TrainingProgression.decrease;
  }
  return TrainingProgression.maintain;
}

TrainingProgression _getTrainingProgression(TrainingData effort, int targetMin, int targetMax) {
  final reps = effort.reps;
  final rpe = effort.rpe;

  if (reps >= targetMax) {
    return TrainingProgression.increase;
  } else if (reps < targetMin) {
    return TrainingProgression.decrease;
  } else {
    final midPoint = (targetMin + targetMax) / 2;
    if (reps >= midPoint) {
      return rpe <= 4 ? TrainingProgression.increase : TrainingProgression.maintain;
    } else {
      return rpe >= 9 ? TrainingProgression.decrease : TrainingProgression.maintain;
    }
  }
}
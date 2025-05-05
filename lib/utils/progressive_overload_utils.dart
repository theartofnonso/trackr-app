import 'dart:math';

import 'package:flutter/material.dart';

import '../colors.dart';

enum TrainingProgression { increase, decrease, maintain }

class TrainingData {
  final int reps;
  final int rpe;
  final double weight;
  final DateTime date;

  TrainingData({
    required this.reps,
    required this.rpe,
    required this.weight,
    required this.date,
  });
}

class TrainingIntensityReport {
  final TrainingProgression progression;
  final int totalSessions;
  final double increaseCount;
  final double decreaseCount;
  final double maintainCount;
  final double averageRPE;
  final String explanation;
  final double confidence;

  TrainingIntensityReport({
    required this.progression,
    required this.totalSessions,
    required this.increaseCount,
    required this.decreaseCount,
    required this.maintainCount,
    required this.averageRPE,
    required this.explanation,
    required this.confidence,
  });
}

TrainingIntensityReport getTrainingProgressionReport(
    {required List<TrainingData> data, required int targetMinReps, required int targetMaxReps}) {
  if (data.isEmpty) {
    return TrainingIntensityReport(
      progression: TrainingProgression.maintain,
      totalSessions: 0,
      increaseCount: 0,
      decreaseCount: 0,
      maintainCount: 0,
      averageRPE: 0,
      explanation: 'No training data available',
      confidence: 0,
    );
  }

  final currentWeight = data.last.weight;
  final currentWeightSessions = data.where((session) => session.weight == currentWeight).toList();

  if (currentWeightSessions.isEmpty) {
    return TrainingIntensityReport(
      progression: TrainingProgression.maintain,
      totalSessions: 0,
      increaseCount: 0,
      decreaseCount: 0,
      maintainCount: 0,
      averageRPE: 0,
      explanation: 'No sessions with current weight',
      confidence: 0,
    );
  }

  double increaseCount = 0; // Changed to double
  double decreaseCount = 0; // Changed to double
  double maintainCount = 0; // Changed to double
  double totalRPE = 0;
  final now = DateTime.now();

  for (final session in currentWeightSessions) {
    final daysAgo = now.difference(session.date).inDays;
    final recencyWeight = _calculateRecencyWeight(daysAgo);

    final suggestion = _getSessionSuggestion(
      session: session,
      targetMin: targetMinReps,
      targetMax: targetMaxReps,
    );

    switch (suggestion) {
      case TrainingProgression.increase:
        increaseCount += recencyWeight;
        break;
      case TrainingProgression.decrease:
        decreaseCount += recencyWeight;
        break;
      case TrainingProgression.maintain:
        maintainCount += recencyWeight;
        break;
    }

    totalRPE += session.rpe;
  }

  final totalWeight = increaseCount + decreaseCount + maintainCount;
  final progression = _determineOverallProgression(
    increaseCount: increaseCount,
    decreaseCount: decreaseCount,
    maintainCount: maintainCount,
  );

  final confidence = _calculateConfidence(
    increaseCount: increaseCount,
    decreaseCount: decreaseCount,
    maintainCount: maintainCount,
    totalWeight: totalWeight,
  );

  return TrainingIntensityReport(
    progression: progression,
    totalSessions: currentWeightSessions.length,
    increaseCount: increaseCount,
    decreaseCount: decreaseCount,
    maintainCount: maintainCount,
    averageRPE: totalRPE / currentWeightSessions.length,
    explanation: _generateExplanation(
      progression: progression,
      confidence: confidence,
      averageRPE: totalRPE / currentWeightSessions.length,
      targetMin: targetMinReps,
      targetMax: targetMaxReps,
    ),
    confidence: confidence,
  );
}

double _calculateRecencyWeight(int daysAgo) {
  return 1 / (1 + daysAgo * 0.1); // Exponential decay
}

TrainingProgression _getSessionSuggestion({
  required TrainingData session,
  required int targetMin,
  required int targetMax,
}) {
  const int rpeIncreaseThreshold = 7;
  const int rpeDecreaseThreshold = 8;

  if (session.reps >= targetMax) {
    return session.rpe < rpeIncreaseThreshold ? TrainingProgression.increase : TrainingProgression.maintain;
  } else if (session.reps < targetMin) {
    return TrainingProgression.decrease;
  } else {
    if (session.rpe <= rpeIncreaseThreshold) {
      return TrainingProgression.increase;
    } else if (session.rpe >= rpeDecreaseThreshold) {
      return TrainingProgression.decrease;
    }
    return TrainingProgression.maintain;
  }
}

TrainingProgression _determineOverallProgression({
  required double increaseCount,
  required double decreaseCount,
  required double maintainCount,
}) {
  final total = increaseCount + decreaseCount + maintainCount;
  if (total == 0) return TrainingProgression.maintain;

  final increaseRatio = increaseCount / total;
  final decreaseRatio = decreaseCount / total;

  if (increaseRatio >= 0.6) return TrainingProgression.increase;
  if (decreaseRatio >= 0.6) return TrainingProgression.decrease;
  return TrainingProgression.maintain;
}

double _calculateConfidence({
  required double increaseCount,
  required double decreaseCount,
  required double maintainCount,
  required double totalWeight,
}) {
  if (totalWeight == 0) return 0;

  final maxCount = [increaseCount, decreaseCount, maintainCount].reduce(max);
  return maxCount / totalWeight;
}

String _generateExplanation({
  required TrainingProgression progression,
  required double confidence,
  required double averageRPE,
  required int targetMin,
  required int targetMax,
}) {
  final _ = averageRPE.toStringAsFixed(1);
  final __ = (confidence * 100).toStringAsFixed(0);

  switch (progression) {
    case TrainingProgression.increase:
      return 'Increase your working weight, current load may be too light. '
          'Aim for $targetMin–$targetMax reps to stay within your range.';

    case TrainingProgression.decrease:
      return 'Lower your working weight, current load may be too heavy. '
          'Adjust to hit $targetMin–$targetMax reps.';

    case TrainingProgression.maintain:
      return 'Maintain your working weight, intensity looks right. '
          'Stay within $targetMin–$targetMax reps.';
  }
}

Color progressionToColor({required TrainingIntensityReport report}) {
  final baseColor = switch (report.progression) {
    TrainingProgression.increase => vibrantGreen,
    TrainingProgression.decrease => Colors.red,
    TrainingProgression.maintain => vibrantBlue,
  };

  return Color.lerp(
    baseColor.withValues(alpha: 0.3),
    baseColor,
    report.confidence,
  )!;
}

List<Color> progressionToGradient({required TrainingIntensityReport report}) {
  final baseColors = switch (report.progression) {
    TrainingProgression.increase => [
        const Color(0xFF4CAF50),
        vibrantGreen,
        const Color(0xFFC8E6C9),
      ],
    TrainingProgression.decrease => [
        const Color(0xFFFF5722),
        const Color(0xFFFF1744),
        const Color(0xFFFFCDD2),
      ],
    TrainingProgression.maintain => [
        const Color(0xFF3763FF),
        vibrantBlue,
        const Color(0xFFBBDEFB),
      ],
  };

  return [
    Color.lerp(baseColors[0].withValues(alpha: 0.7), baseColors[0], report.confidence)!,
    Color.lerp(baseColors[1].withValues(alpha: 0.7), baseColors[1], report.confidence)!,
    Color.lerp(baseColors[2].withValues(alpha: 0.7), baseColors[2], report.confidence)!,
  ];
}

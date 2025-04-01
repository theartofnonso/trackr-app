int calculateReadinessScore({
  required int fatigue,
  required int soreness,
}) {
  // Validate inputs (1–5 only).
  if (fatigue < 1 || fatigue > 5 ||
      soreness < 1 || soreness > 5) {
    return -1;
  }

  // Define new weights (they must sum to 1.0)
  const double kFatigueWeight = 0.60;
  const double kSorenessWeight = 0.40;

  // Normalize each metric to a 0–1 "subscore" for negative metrics:
  //  - 1 represents minimal issue (best readiness).
  //  - 5 represents worst issue (lowest readiness).
  // Using (5 - metric) / 4 maps 1 → 1.0, 5 → 0.0.
  final double fatigueRatio = (5 - fatigue) / 4;
  final double sorenessRatio = (5 - soreness) / 4;

  // Weighted sum of subscores (range: 0–1)
  final double weightedSum =
      (fatigueRatio * kFatigueWeight) +
          (sorenessRatio * kSorenessWeight);

  // Convert from 0–1 to 0–100 scale
  double totalScore = weightedSum * 100;

  // Clamp to [0, 100] just to be safe
  totalScore = totalScore.clamp(0, 100);

  return totalScore.toInt();
}

String getTrainingGuidance({required int readinessScore}) {
  // Ensure the score is within 0–100.
  if (readinessScore < 0) readinessScore = 0;
  if (readinessScore > 100) readinessScore = 100;

  if (readinessScore <= 29) {
    return "🛑 Very poor readiness. High pain, fatigue, or soreness likely. "
        "Consider rest, gentle mobility work, or seek medical advice.";
  } else if (readinessScore <= 49) {
    return "⚠️ Low readiness. Notable issues like pain, fatigue, or heavy DOMS. "
        "Reduce intensity and focus on recovery activities.";
  } else if (readinessScore <= 69) {
    return "🤔 Mixed readiness. Some fatigue or soreness is present. "
        "Train at a moderate pace with extra focus on technique and form.";
  } else if (readinessScore <= 84) {
    return "👍 Generally solid readiness. Minor aches or tiredness possible. "
        "Proceed with your planned workout but remain mindful of any overstress.";
  } else {
    return "💯 Optimal readiness. Minimal pain or fatigue. "
        "Suitable for higher intensity or advanced training, if desired.";
  }
}

/// Perceived Fatigue (1–5)
Map<int, String> perceivedFatigueScale = {
  1: "😌 Fresh and alert, no fatigue",
  2: "🙂 Slight tiredness, hardly noticeable",
  3: "😐 Noticeable fatigue, but manageable",
  4: "😫 Quite tired, training will be challenging",
  5: "💤 Completely drained, training not recommended"
};

/// Muscle Soreness (1–5)
Map<int, String> muscleSorenessScale = {
  1: "😌 No soreness, muscles feel and pain-free",
  2: "🙂 Slight tightness or tenderness",
  3: "😐 Noticeable soreness, but still manageable",
  4: "😣 Significant soreness, movement is somewhat restricted",
  5: "💀 Severe soreness, training will be uncomfortable or painful"
};

/// Sleep Duration (1–5)
Map<int, String> sleepDurationScale = {
  1: "😴 Severely lacking (<5 hours)",
  2: "😕 Under recommended (5–6 hours)",
  3: "😐 Slightly under recommended (6–7 hours)",
  4: "🙂 Good rest (7–8 hours)",
  5: "💤 Excellent (8+ hours)"
};
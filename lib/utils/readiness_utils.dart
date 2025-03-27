/// Calculates the overall recovery score based on four metrics.
///
/// Each metric should be in the range 0–10. Higher pain, fatigue, and soreness
/// reduce the final score, while higher energy increases it.
///
/// Returns a [int] between 0 and 100.
int calculateReadinessScore({
  required int pain,
  required int fatigue,
  required int soreness,
}) {
  // Validate inputs
  // (Allows only 1–10; throw an error if outside this range)
  if (pain < 1 || pain > 10 || fatigue < 1 || fatigue > 10 || soreness < 1 || soreness > 10) {
    throw ArgumentError('All input values must be between 1 and 10.');
  }

  // Define weights (must sum to 1.0 for a proper 0–100 score)
  const double kPainWeight = 0.50;
  const double kFatigueWeight = 0.25;
  const double kSorenessWeight = 0.25;

  // Convert each metric to a 0–1 "subscore"
  // For "negative" metrics (like pain):
  // - 1 represents minimal issue (max readiness).
  // - 10 represents worst issue (min readiness).
  // Using (10 - metric) / 9 normalizes 1–10 into 1.0–0.0.
  final double painRatio = (10 - pain) / 9; // Range: 1 => 1.0, 10 => 0.0
  final double fatigueRatio = (10 - fatigue) / 9; // Range: 1 => 1.0, 10 => 0.0
  final double sorenessRatio = (10 - soreness) / 9; // Range: 1 => 1.0, 10 => 0.0

  // Weighted sum of subscores (0–1)
  final double weightedSum =
      (painRatio * kPainWeight) + (fatigueRatio * kFatigueWeight) + (sorenessRatio * kSorenessWeight);

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

/// Calculates the overall recovery score based on four metrics.
/// 
/// Each metric should be in the range 0–10. Higher pain, fatigue, and soreness
/// reduce the final score, while higher energy increases it.
/// 
/// Returns a [int] between 0 and 100.
int calculateReadinessScore({required int pain, required int fatigue, required int soreness}) {
  // Optional: Validate inputs or clamp
  if (pain < 0 || pain > 10 ||
      fatigue < 0 || fatigue > 10 ||
      soreness < 0 || soreness > 10) {
    throw ArgumentError('All input values must be between 0 and 10.');
  }

  // Define weights
  const double kPainWeight = 0.30;
  const double kFatigueWeight = 0.25;
  const double kSorenessWeight = 0.25;

  // Calculate subscores
  final double painSubscore     = (10 - pain) / 10 * 100;  // Negative metric
  final double fatigueSubscore  = (10 - fatigue) / 10 * 100;  // Negative metric
  final double sorenessSubscore = (10 - soreness) / 10 * 100; // Negative metric

  // Weighted sum
  final double totalScore =
      (painSubscore     * kPainWeight) +
          (fatigueSubscore  * kFatigueWeight) +
          (sorenessSubscore * kSorenessWeight);

  // Clamp to [0, 100]
  return totalScore.clamp(0.0, 100.0).toInt();
}

String getTrainingGuidance({required int readinessScore}) {
  // Ensure the score is within 0–100.
  if (readinessScore < 0) readinessScore = 0;
  if (readinessScore > 100) readinessScore = 100;

  if (readinessScore <= 29) {
    return "Severe (0–29): Very poor readiness. High pain, fatigue, or soreness likely. "
        "Consider rest, gentle mobility work, or seek medical advice.";
  } else if (readinessScore <= 49) {
    return "Poor (30–49): Low readiness. Notable issues like pain, fatigue, or heavy DOMS. "
        "Reduce intensity and focus on recovery activities.";
  } else if (readinessScore <= 69) {
    return "Moderate (50–69): Mixed readiness. Some fatigue or soreness is present. "
        "Train at a moderate pace with extra focus on technique and form.";
  } else if (readinessScore <= 84) {
    return "Good (70–84): Generally solid readiness. Minor aches or tiredness possible. "
        "Proceed with your planned workout but remain mindful of any overstress.";
  } else {
    return "Excellent (85–100): Optimal readiness. Minimal pain or fatigue. "
        "Suitable for higher intensity or advanced training, if desired.";
  }
}
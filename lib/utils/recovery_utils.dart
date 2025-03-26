/// Calculates the overall recovery score based on four metrics.
/// 
/// Each metric should be in the range 0–10. Higher pain, fatigue, and soreness
/// reduce the final score, while higher energy increases it.
/// 
/// Returns a [int] between 0 and 100.
int calculateRecoveryScore({required int pain, required int fatigue, required int soreness, required  int energy}) {
  // Optional: Validate inputs or clamp
  if (pain < 0 || pain > 10 ||
      fatigue < 0 || fatigue > 10 ||
      soreness < 0 || soreness > 10 ||
      energy < 0 || energy > 10) {
    throw ArgumentError('All input values must be between 0 and 10.');
  }

  // Define weights
  const double kPainWeight = 0.30;
  const double kFatigueWeight = 0.25;
  const double kSorenessWeight = 0.25;
  const double kEnergyWeight = 0.20;

  // Calculate subscores
  final double painSubscore     = (10 - pain) / 10 * 100;  // Negative metric
  final double fatigueSubscore  = (10 - fatigue) / 10 * 100;  // Negative metric
  final double sorenessSubscore = (10 - soreness) / 10 * 100; // Negative metric
  final double energySubscore   = (energy / 10) * 100;        // Positive metric

  // Weighted sum
  final double totalScore =
      (painSubscore     * kPainWeight) +
          (fatigueSubscore  * kFatigueWeight) +
          (sorenessSubscore * kSorenessWeight) +
          (energySubscore   * kEnergyWeight);

  // Clamp to [0, 100]
  return totalScore.clamp(0.0, 100.0).toInt();
}
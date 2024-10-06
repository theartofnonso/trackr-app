
enum StrengthEnduranceHypertrophyType {
  strength("Strength", "Boost muscle growth, strengthen bones, enhance metabolism, improve functional fitness, and reduce injury risk."),
  endurance("Endurance", "Improve stamina, cardiovascular health, and overall fitness."),
  hypertrophy("Hypertrophy", "Build muscle size and strength for a balanced physique.");

  const StrengthEnduranceHypertrophyType(this.name, this.description);

  final String name;
  final String description;
}
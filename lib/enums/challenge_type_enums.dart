enum ChallengeType {
  weekly, reps, days, weight;

  static ChallengeType fromString(String string) {
    return ChallengeType.values.firstWhere((value) => value.name.toLowerCase() == string.toLowerCase());
  }
}
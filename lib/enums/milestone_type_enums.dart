enum MilestoneType {
  weekly, reps, days, weight;

  static MilestoneType fromString(String string) {
    return MilestoneType.values.firstWhere((value) => value.name.toLowerCase() == string.toLowerCase());
  }
}
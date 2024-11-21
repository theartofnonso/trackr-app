enum MilestoneType {
  weekly, reps, days, hours;

  String toJson() => name;

  static MilestoneType fromJson(String string) {
    return MilestoneType.values.firstWhere((value) => value.name.toLowerCase() == string.toLowerCase());
  }
}
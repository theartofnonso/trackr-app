enum RoutineScheduleType {
  days,
  none;

  String toJson() => name;

  static RoutineScheduleType fromJson(String string) {
    return RoutineScheduleType.values.firstWhere((value) => value.name.toLowerCase() == string.toLowerCase());
  }
}

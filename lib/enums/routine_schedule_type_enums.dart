enum RoutineScheduleType {
  days,
  intervals,
  none;

  static RoutineScheduleType fromJson(String string) {
    return RoutineScheduleType.values.firstWhere((value) => value.name.toLowerCase() == string.toLowerCase());
  }
}

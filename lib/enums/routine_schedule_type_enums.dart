enum RoutineScheduleType {
  days,
  intervals,
  none;

  static RoutineScheduleType fromString(String string) {
    return RoutineScheduleType.values.firstWhere((value) => value.name.toLowerCase() == string.toLowerCase());
  }
}

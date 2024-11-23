enum RoutinePlanWeeks {
  four(weeks: 4),
  six(weeks: 6),
  eight(weeks: 8),
  twelve(weeks: 12);

  final int weeks;

  const RoutinePlanWeeks({required this.weeks});
}
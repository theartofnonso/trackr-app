enum RoutinePlanSessions {
  two(frequency: 2),
  three(frequency: 3),
  four(frequency: 4),
  five(frequency: 5),
  six(frequency: 6);

  final int frequency;

  const RoutinePlanSessions({required this.frequency});
}
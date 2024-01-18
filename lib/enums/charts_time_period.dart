
enum ChartTimePeriod {
  thisWeek("This Week"), thisMonth("This Month"), allTime("All Time");

  const ChartTimePeriod(this.label);

  final String label;
}

enum ChartTimePeriod {
  thisWeek("This Week"), thisMonth("This Month"), thisYear("This Year");

  const ChartTimePeriod(this.label);

  final String label;
}
enum HistoricalTimePeriod {
  lastThreeMonths("Last 3 months"), lastOneYear("Last 1 year"), allTime("All Time");

  const HistoricalTimePeriod(this.label);

  final String label;
}

enum CurrentTimePeriod {
  thisWeek("This Week"), thisMonth("This Month"), thisYear("This Year"), allTime("All Time");

  const CurrentTimePeriod(this.label);

  final String label;
}
enum HistoricalDates {
  lastThreeMonths("Last 3 months"), lastOneYear("Last 1 year"), allTime("All Time");

  const HistoricalDates(this.label);

  final String label;
}

enum CurrentDates {
  allTime("This Week"), lastThreeMonths("This Month"), lastYear("This Year");

  const CurrentDates(this.label);

  final String label;
}
enum AchievementType {
  days12("12 Days Trackd", "Log at least 3 sessions per week for a month"),
  days30("30 Days Trackd", "Log 30 sessions"),
  days75("75 Hard", "Log 75 sessions"),
  days100("100 Days Trackd", "Log 100 sessions"),
  supersetSpecialist("Superset Specialist", "Log 20 sessions with at least one superset"),
  strongerThanEver("Stronger than ever", "Log 10 sessions with a PB"),
  oneMoreRep("One More Rep", "Set a goal to increase the number of reps in a specific exercise"),
  timeUnderTension("Time under tension", "Set a goal to increase the duration in a specific exercise"),
  maxOutMadness("Max Out Madness", "Set a goal to increase the maximum weight lifted in a specific compound exercise"),
  obsessed("Obsessed", "Log at least one session for 12 consecutive weeks"),
  neverSkipAMonday("Never Skip a Monday", "Log sessions for 12 consecutive mondays"),
  neverSkipALegDay("Never Skip a Leg Day", "Log sessions with at least one leg exercise for 12 consecutive weeks"),
  sweatEquity("Sweat Equity", "Accumulate 20 hours of strength training"),
  weekendWarrior("Weekend Warrior", "Log a session on both Saturday and Sunday for four consecutive weeks"),
  bodyweightChampion("Bodyweight Champion", "Log 20 sessions with at least one bodyweight exercise"),
  twiceAsStrong("Twice as Strong", "Achieve a 2x body weight deadlift"),
  twiceAsLow("Twice as Low", "Achieve a 2x body weight squat");

  const AchievementType(this.title, this.description);

  final String title;
  final String description;
}
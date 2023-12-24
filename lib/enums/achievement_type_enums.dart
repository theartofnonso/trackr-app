enum AchievementType {
  days12("12 Days Trackd", "Log at least 3 sessions per week for a month", 12),
  days30("30 Days Trackd", "Log 30 sessions", 30),
  days75("75 Hard", "Log 75 sessions", 75),
  days100("100 Days Trackd", "Log 100 sessions", 100),
  supersetSpecialist("Superset Specialist", "Log 20 sessions with at least one superset", 20),
  strongerThanEver("Stronger than ever", "Log 10 sessions with a PB", 10),
  oneMoreRep("One More Rep", "Set a goal to increase the number of reps in a specific exercise", 100),
  fiveMinutesToGo("5 Minutes To Go", "Log 50 sessions, each with at least a duration of 5 minutes in a single set", 5),
  tenMinutesToGo("10 Minutes To Go", "Log 50 sessions, each with at least a duration of 10 minutes in a single set.", 10),
  fifteenMinutesToGo("15 Minutes To Go", "Log 50 sessions, each with at least a duration of 15 minutes in a single set.", 15),
  timeUnderTension("Time Under Tension", "Log 50 sessions, each with at least a duration of 30 minutes in a single set.", 30),
  maxOutMadness("Max Out Madness", "Set a goal to increase the maximum weight lifted in a specific compound exercise", 0),
  obsessed("Obsessed", "Log at least one session for 16 consecutive weeks", 16),
  neverSkipAMonday("Never Skip a Monday", "Log a session for 16 consecutive mondays", 16),
  neverSkipALegDay("Never Skip a Leg Day", "Log at least one leg exercise in a session for 16 consecutive weeks", 16),
  sweatEquity("Sweat Equity", "Accumulate 20 hours of strength training", 100),
  weekendWarrior("Weekend Warrior", "Log a session on both Saturday and Sunday for eight consecutive weeks", 8),
  bodyweightChampion("Bodyweight Champion", "Log 20 sessions with at least one bodyweight exercise", 20),
  twiceAsStrong("Twice as Strong", "Achieve a 2x body weight deadlift", 0),
  twiceAsLow("Twice as Low", "Achieve a 2x body weight squat", 0);

  const AchievementType(this.title, this.description, this.target);

  final String title;
  final String description;
  final int target;
}
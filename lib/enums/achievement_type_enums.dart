enum AchievementType {
  days12("12 Days Trackd", "Log at least 3 sessions per week for a month", 12,
      "12 Days Trackd focuses on establishing a consistent workout routine. It is a great way to get started with Trackr"),
  days30("30 Days Trackd", "Log 30 sessions", 30,
      "30 Days Trackd is designed to help you establish a consistent workout routine. It is a great way to round up your first month with Trackr"),
  days75("75 Hard", "Log 75 sessions", 75,
      "75 Hard is a challenge that focuses on establishing a consistent workout routine. It is a great way to get started with Trackr"),
  days100("100 Days Trackd", "Log 100 sessions", 100,
      "100 Days Trackd is designed to help you establish a consistent workout routine. It is a great way to round up your first 100 days with Trackr"),
  supersetSpecialist("Superset Specialist", "Log 50 sessions with at least one superset in each", 50,
      "Superset Specialist focuses on incorporating supersets into your workout routine. Supersets are a great way to increase the intensity of your workout and save time as well"),
  strongerThanEver("Stronger than ever", "Accumulate 1 million kg of training for exercies with weights", 1000000,
      "Stronger than ever focuses on exercising consistently and lifting heavy weights"),
  fiveMinutesToGo(
      "5 Minutes To Go",
      "Log 50 sessions, each with at least one duration exercise of 5 minutes in a single set",
      5,
      "5 Minutes To Go encourages you to push yourself to exercise for longer durations. It is a great way to increase the intensity of your workout"),
  tenMinutesToGo(
      "10 Minutes To Go",
      "Log 50 sessions, each with at least one duration exercise of 10 minutes in a single set.",
      10,
      "10 Minutes To Go encourages you to push yourself to exercise for even longer durations. It is a great way to increase the intensity of your workout"),
  fifteenMinutesToGo(
      "15 Minutes To Go",
      "Log 50 sessions, each with at least one duration exercise of 15 minutes in a single set.",
      15,
      "15 Minutes To Go encourages you to push yourself to exercise for even longer durations. It is a great way to increase the intensity of your workout"),
  timeUnderTension("Time Under Tension", "Accumulate 100 hours of training for any duration exercises", 100,
      "Time Under Tension focuses on duration exercises. It is a great way to increase the intensity of your workout"),
  obsessed("Obsessed", "Log at least one session for 16 consecutive weeks", 16,
      "Obsessed focuses on adhering to a four-month workout regimen, a significant duration to notice fitness outcomes. Additionally, it serves as an effective method for establishing a consistent exercise routine"),
  neverSkipAMonday("Never Skip a Monday", "Log a session for 16 consecutive mondays", 16,
      "Never Skip a Monday focuses on adhering to a four-month workout regimen, a significant duration to notice fitness outcomes. Additionally, it serves as an effective method for establishing a consistent exercise routine"),
  neverSkipALegDay("Never Skip a Leg Day", "Log at least one leg exercise in a session for 16 consecutive weeks", 16,
      "Never Skip a Leg Day focuses on adhering to a four-month workout regimen that encourages you to train legs. Additionally, it serves as an effective method for establishing a consistent leg exercise routine"),
  sweatEquity("Sweat Equity", "Accumulate 100 hours of training sessions", 100,
      "Sweat Equity is a great way to embrace the time spent exercising and lifting heavy weights"),
  weekendWarrior("Weekend Warrior", "Log a session on both Saturday and Sunday for eight consecutive weeks", 8,
      "Weekend Warrior focuses on adhering to a two-month workout regimen for individuals with a busy schedule. Additionally, it serves as an effective method for establishing a consistent weekend exercise routine"),
  bodyweightChampion("Bodyweight Champion", "Accumulate 100 bodyweight exercises", 100,
      "Bodyweight Champion focuses on bodyweight exercises. It is designed to encourage you to add bodyweight exercises to your workout routine for a more well-rounded workout"),
  // maxOutMadness("Max Out Madness", "Set a goal to increase the maximum weight lifted in a specific compound exercise", 0),
  // twiceAsStrong("Twice as Strong", "Achieve a 2x body weight deadlift", 0),
  // twiceAsLow("Twice as Low", "Achieve a 2x body weight squat", 0)
  oneMoreRep("One More Rep", "Accumulate 10000 reps of training", 10000,
      "One More Rep is a great way to challenge yourself to do more reps, thereby increasing the intensity of your workout"),
  ;

  const AchievementType(this.title, this.description, this.target, this.tip);

  final String title;
  final String description;
  final int target;
  final String tip;
}

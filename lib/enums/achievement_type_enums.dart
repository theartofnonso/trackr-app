enum AchievementType {
  days12(
      "12 Days of Gyming",
      "Log at least 3 sessions per week for a month",
      12,
      "12 Days of Gyming focuses on establishing a consistent workout routine. It is a great way to get started with Trackr.",
      "Congratulations! You've hit the '12 Days of Gyming' milestone by logging at least 3 sessions per week for an entire month."),
  days30(
      "30 Days Trackd",
      "Log 30 sessions",
      30,
      "30 Days Trackd is designed to help you establish a consistent workout routine. It is a great way to round up your first month with Trackr.",
      "Well done on completing one month with Trackr!"),
  days75(
      "75 Hard",
      "Log 75 sessions",
      75,
      "75 Hard is a challenge that focuses on establishing a consistent workout routine. It is a great way to get started with Trackr.",
      "Hurray! You have completed Trackr's own 75 Hard challenge."),
  days100(
      "100 Days Trackd",
      "Log 100 sessions",
      100,
      "100 Days Trackd is designed to help you establish a consistent workout routine. It is a great way to round up your first 100 days with Trackr.",
      "Congratulations on logging 100 days with Trackr!"),
  supersetSpecialist(
      "Superset Specialist",
      "Log 50 sessions with at least one superset",
      50,
      "Superset Specialist focuses on incorporating supersets into your workout routine. Supersets are a great way to increase the intensity of your workout and save time as well.",
      "Congratulations! You've successfully completed a remarkable journey of 50 workout sessions, each powered with the intensity of supersets."),
  strongerThanEver(
      "Stronger than ever",
      "Accumulate 1 million kg of training for exercises with weights",
      1000000,
      "Stronger than ever focuses on exercising consistently and lifting heavy weights.",
      "Incredible Achievement Unlocked! You've successfully lifted 1 million kg of weights, showcasing remarkable strength and perseverance."),
  fiveMinutesToGo(
    "5 Minutes To Go",
    "Log 5 sessions, each with at least one duration exercise of 5 minutes in a single set",
    5,
    "5 Minutes To Go encourages you to push yourself to exercise for longer durations. It is a great way to increase the intensity of your workout.",
    "Congratulations on Reaching the 5-Minute Milestone in 5 Sessions!",
  ),
  tenMinutesToGo(
      "10 Minutes To Go",
      "Log 10 sessions, each with at least one duration exercise of 10 minutes in a single set",
      10,
      "10 Minutes To Go encourages you to push yourself to exercise for even longer durations. It is a great way to increase the intensity of your workout.",
      "Congratulations on Reaching the 10-Minute Milestone in 10 Sessions!"),
  fifteenMinutesToGo(
      "15 Minutes To Go",
      "Log 15 sessions, each with at least one duration exercise of 15 minutes in a single set",
      15,
      "15 Minutes To Go encourages you to push yourself to exercise for even longer durations. It is a great way to increase the intensity of your workout.",
      "Congratulations on Reaching the 15-Minute Milestone in 15 Sessions!"),
  timeUnderTension(
      "Time Under Tension",
      "Accumulate 10 hours of training for any duration exercises",
      10,
      "Time Under Tension focuses on duration exercises. It is a great way to increase the intensity of your workout.",
      "Fantastic Achievement! You've successfully dedicated 100 hours to duration exercises, showcasing your incredible commitment and endurance."),
  obsessed(
      "Obsessed",
      "Log at least one session for 16 consecutive weeks.",
      16,
      "Obsessed focuses on adhering to a four-month workout regimen, a significant duration to notice fitness outcomes. Additionally, it serves as an effective method for establishing a consistent exercise routine.",
      "Congratulations on your unwavering commitment! You've successfully logged sessions for 16 consecutive weeks, showcasing remarkable dedication and discipline."),
  neverSkipAMonday(
      "Never Skip a Monday",
      "Log a session for 16 consecutive mondays.",
      16,
      "Never Skip a Monday focuses on adhering to a four-month workout regimen, a significant duration to notice fitness outcomes. Additionally, it serves as an effective method for establishing a consistent exercise routine.",
      "Congratulations, for 16 consecutive Mondays, you've shown remarkable dedication and discipline. Your commitment to starting each week strong is truly inspiring."),
  neverSkipALegDay(
      "Never Skip a Leg Day",
      "Log at least one leg exercise in a session for 16 consecutive weeks",
      16,
      "Never Skip a Leg Day focuses on adhering to a four-month workout regimen that encourages you to train legs. Additionally, it serves as an effective method for establishing a consistent leg exercise routine.",
      "Congratulations on conquering the 'Never Skip a Leg Day' challenge! Your commitment over the past 16 weeks has significantly strengthened your leg muscles and overall endurance."),
  sweatMarathon(
      "Sweat-A-Thon",
      "Accumulate 100 hours of training session.",
      100,
      "Sweat-A-Thon is a great way to embrace the time spent exercising and lifting heavy weights.",
      "Outstanding Achievement! You've dedicated 100 hours to training, showcasing remarkable commitment and perseverance. This is more than just a milestone, it's dedication."),
  weekendWarrior(
      "Weekend Warrior",
      "Log a session on either Saturday or Sunday for sixteen consecutive weeks",
      16,
      "Weekend Warrior focuses on adhering to a four-month workout regimen for individuals with a busy schedule. Additionally, it serves as an effective method for establishing a consistent weekend exercise routine.",
      "Congratulations on mastering the 'Weekend Warrior' challenge! Your unwavering commitment to fitness over the past sixteen weeks, even on weekends, is truly commendable."),
  bodyweightChampion(
      "Bodyweight Champion",
      "Accumulate 100 bodyweight exercises",
      100,
      "Bodyweight Champion is designed to encourage you to add bodyweight exercises to your workout routine for a more well-rounded workout.",
      "Congratulations on reaching a major milestone! You've successfully completed 100 bodyweight exercises."),
  // maxOutMadness("Max Out Madness", "Set a goal to increase the maximum weight lifted in a specific compound exercise", 0),
  // twiceAsStrong("Twice as Strong", "Achieve a 2x body weight deadlift", 0),
  // twiceAsLow("Twice as Low", "Achieve a 2x body weight squat", 0)
  oneMoreRep(
      "One More Rep",
      "Accumulate 10000 reps of training",
      10000,
      "One More Rep is a great way to challenge yourself to do more reps, thereby increasing the intensity of your workout.",
      "Outstanding Achievement Unlocked! You've successfully completed 10,000 reps, showcasing remarkable dedication and strength."),
  ;

  const AchievementType(this.title, this.description, this.target, this.tip, this.completionMessage);

  final String title;
  final String description;
  final int target;
  final String tip;
  final String completionMessage;
}

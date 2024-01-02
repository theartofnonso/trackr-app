enum DailyReminder {
  motivationMonday(1, "Monday", "Motivation Monday", "Start Strong, Stay Strong! Unleash your potential today."),
  triumphTuesday(2, "Tuesday", "Triumph Tuesday", "Every step counts. Today's effort builds tomorrow's success."),
  wellnessWednesday(3, "Wednesday", "Wellness Wednesday", "Nourish your body and soul. Make today's workout count!"),
  thriveThursday(4, "Thursday", "Thrive Thursday", "Push beyond limits. Your best self awaits."),
  fitnessFriday(5, "Friday", "Fitness Friday", "End the week on a high note! Conquer today's challenge."),
  staminaSaturday(6, "Saturday", "Stamina Saturday", "Weekend warrior mode: ON. Power through your goals."),
  successSunday(7, "Sunday", "Success Sunday", "Celebrate your achievements. Prepare for another victorious week!"),
  everyday(999, "Everyday", "It's a great day to train", "Everyday is a new opportunity. Make it count!");

  final int weekday;
  final String day;
  final String title;
  final String subtitle;

  const DailyReminder(this.weekday, this.day, this.title, this.subtitle);
}
enum PostHogAnalyticsEvent {
  logRoutine(displayName: "Workout Session Logged"),
  createRoutineTemplate(displayName: "Workout Template Created"),
  logActivity(displayName: "Activity Logged"),
  createRoutineTemplateAI(displayName: "Workout Template Created With AI"),
  generateRoutineLogReport(displayName: "Workout Session Report Generated"),
  generateMonthlyInsights(displayName: "Monthly Insights Generated"),
  generateMuscleGroupTrainingReport(displayName: "Muscle Group Training Report Generated"),
  shareRoutineLogSummary(displayName: "Routine Log Summary Shared"),
  shareCalendar(displayName: "Calender Shared"),
  shareMonitor(displayName: "Monitor Shared"),
  shareMilesStone(displayName: "Milestone Shared"),
  shareRoutineLogAsLink(displayName: "Routine Log as Link Shared"),
  shareRoutineTemplateAsLink(displayName: "Routine Template as Link Shared"),
  shareRoutineLogAsText(displayName: "Routine Log as Text Shared"),
  shareRoutineTemplateAsText(displayName: "Routine Template as Text Shared"),
  createExercise(displayName: "Exercise Created");

  final String displayName;

  const PostHogAnalyticsEvent({required this.displayName});
}

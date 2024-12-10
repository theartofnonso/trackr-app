enum PostHogAnalyticsEvent {

  /// Logging
  logRoutine(displayName: "log:routine"),
  logActivity(displayName: "log:activity"),

  /// Creating
  createRoutineTemplate(displayName: "create:routine_template"),
  createRoutineTemplateAI(displayName: "create:routine_template_ai"),
  createExercise(displayName: "create:exercise"),

  /// Reports
  generateRoutineLogReport(displayName: "report:routine_log_session_generate"),
  generateMonthlyInsights(displayName: "report:monthly_insights_generate"),
  generateMuscleGroupTrainingReport(displayName: "report:muscle_group_training_generate"),

  /// Sharing
  shareRoutineLogSummary(displayName: "share:routine_log_summary"),
  shareCalendar(displayName: "share:calender"),
  shareMonitor(displayName: "share:monitor"),
  shareMilesStone(displayName: "share:milestone"),
  shareRoutineLogAsLink(displayName: "share:routine_log_as_link"),
  shareRoutineLogAsText(displayName: "share:routine_log_as_text"),
  shareRoutineTemplateAsLink(displayName: "share:routine_template_as_link"),
  shareRoutineTemplateAsText(displayName: "share:routine_template_as_text"),;

  final String displayName;

  const PostHogAnalyticsEvent({required this.displayName});
}

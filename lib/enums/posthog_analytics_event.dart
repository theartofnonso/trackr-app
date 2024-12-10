enum PostHogAnalyticsEvent {

  /// Logging
  logRoutine(displayName: "log:routine"),
  logActivity(displayName: "log:activity"),

  /// Creating
  createRoutineTemplate(displayName: "create:routine_template"),
  createRoutineTemplateAI(displayName: "create:ai_routine_template"),
  createExercise(displayName: "create:exercise"),

  /// Reports
  generateRoutineLogReport(displayName: "report:routine_log_session_generate"),
  generateMonthlyInsights(displayName: "report:monthly_insights_generate"),
  generateMuscleGroupTrainingReport(displayName: "report:muscle_group_training_generate"),

  shareRoutineLogSummary(displayName: "routine_log_summary:routine_log_stats_share"),
  shareRoutineLogAsLink(displayName: "routine_log_summary:routine_log_link_copy"),
  shareRoutineLogAsText(displayName: "routine_log_summary:routine_log_text_copy"),

  /// Sharing

  shareCalendar(displayName: "share:calender"),
  shareMonitor(displayName: "share:monitor"),
  shareMilesStone(displayName: "share:milestone"),
  shareRoutineTemplateAsLink(displayName: "share:routine_template_as_link"),
  shareRoutineTemplateAsText(displayName: "share:routine_template_as_text"),;

  final String displayName;

  const PostHogAnalyticsEvent({required this.displayName});
}

enum PostHogAnalyticsEvent {
  /// Logging
  logRoutine(displayName: "routine_log_editor:routine_log_create"),
  logActivity(displayName: "activity_picker:activity_log_create"),
  logRecovery(displayName: "muscle_recovery:recovery_log_create"),

  /// Creating
  createRoutineTemplate(
      displayName: "routine_template_editor:routine_template_create"),
  createExercise(displayName: "exercise_editor:exercise_create"),
  createRoutinePlan(displayName: "routine_plan_editor:routine_plan_create"),

  /// Reports
  generateRoutineLogReport(displayName: "report:routine_log_session_generate"),
  generateMonthlyInsights(displayName: "report:monthly_insights_generate"),
  generateMuscleGroupTrainingReport(
      displayName: "report:muscle_group_training_generate"),

  /// Sharing
  shareRoutineLogSummary(
      displayName: "routine_log_summary:routine_log_stats_share"),
  shareRoutineLogAsText(
      displayName: "routine_log_summary:routine_log_text_copy"),

  shareRoutineTemplateAsText(
      displayName: "routine_template:routine_template_text_copy"),

  shareRoutinePlanAsText(displayName: "routine_plan:routine_plan_text_copy"),

  shareCalendar(displayName: "app:calender_share");

  final String displayName;

  const PostHogAnalyticsEvent({required this.displayName});
}

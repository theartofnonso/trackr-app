import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import '../enums/share_content_type_enum.dart';

void logEvent({required String name, required Map<String, Object> parameters}) async {
  await FirebaseAnalytics.instance.logEvent(
    name: name,
    parameters: <String, dynamic>{
      'screen': 'routine_templates.dart',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    },
  );
}

void recordTemplateSessionEvent() {
  final event = AnalyticsEvent('TemplateSession');
  Amplify.Analytics.recordEvent(event: event);
}

void recordEmptySessionEvent() {
  final event = AnalyticsEvent('EmptySession');
  Amplify.Analytics.recordEvent(event: event);
}

void recordCreateExerciseEvent() {
  final event = AnalyticsEvent('CreateExercise');
  Amplify.Analytics.recordEvent(event: event);
}

void recordVisitTemplateEditorEvent() {
  final event = AnalyticsEvent('VisitTemplateEditor');
  Amplify.Analytics.recordEvent(event: event);
}

void recordCreateTemplateFromLogEvent() {
  final event = AnalyticsEvent('TemplateFromLog');
  Amplify.Analytics.recordEvent(event: event);
}

void recordMilestoneAchievementEvent() {
  final event = AnalyticsEvent('MilestoneAchieved');
  Amplify.Analytics.recordEvent(event: event);
}

void recordViewExerciseMetricsEvent() {
  final event = AnalyticsEvent('ViewExerciseMetrics');
  Amplify.Analytics.recordEvent(event: event);
}

void recordViewMuscleTrendEvent() {
  final event = AnalyticsEvent('ViewMuscleTrend');
  Amplify.Analytics.recordEvent(event: event);
}

void recordToggleNotificationsEvent() {
  final event = AnalyticsEvent('ToggleNotifications');
  Amplify.Analytics.recordEvent(event: event);
}

void recordShareEvent({required ShareContentType contentType}) {
  final event = AnalyticsEvent('ShareEvent');
  event.customProperties.addStringProperty("content", contentType.name);
  Amplify.Analytics.recordEvent(event: event);
}

void recordViewMuscleFrequencyChartEvent() {
  final event = AnalyticsEvent('ViewMuscleFrequencyChart');
  Amplify.Analytics.recordEvent(event: event);
}

void recordViewMilestonesEvent() {
  final event = AnalyticsEvent('ViewMilestones');
  Amplify.Analytics.recordEvent(event: event);
}

void recordSuperSetEvent() {
  final event = AnalyticsEvent('SuperSet');
  Amplify.Analytics.recordEvent(event: event);
}

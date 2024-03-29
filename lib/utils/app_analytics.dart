import 'package:amplify_flutter/amplify_flutter.dart';

import '../enums/share_content_type_enum.dart';

void recordEmptySessionEvent() {
  final event = AnalyticsEvent('EmptySession');
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

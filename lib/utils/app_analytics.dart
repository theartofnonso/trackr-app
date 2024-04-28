import 'package:posthog_flutter/posthog_flutter.dart';

import '../enums/share_content_type_enum.dart';

void workoutSessionLogged() {
  Posthog().capture(
    eventName: 'workout_session_logged',
  );
}

void contentShared({required ShareContentType contentType}) {
  Posthog().capture(
    eventName: 'content_shared',
  );
}

void identifyUser({required String userId}) {
  Posthog().identify(userId: userId);
}

import 'package:firebase_analytics/firebase_analytics.dart';

void logEvent({required String name, required Map<String, Object> parameters}) async {
  await FirebaseAnalytics.instance.logEvent(
    name: name,
    parameters: <String, dynamic>{
      'screen': 'routine_templates_screen.dart',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    },
  );
}
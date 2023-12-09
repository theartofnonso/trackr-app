import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

import '../models/Routine.dart';
import '../screens/editors/routine_editor_screen.dart';
import '../routine_log_preview_screen.dart';
import '../shared_prefs.dart';

Future<void> navigateToRoutineEditor(
    {required BuildContext context,
    Routine? routine,
    required RoutineEditorMode mode,
    TemporalDateTime? createdAt,
    VoidCallback? onShowRoutineBanner,
    VoidCallback? onCloseRoutineBanner}) async {
  final result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => RoutineEditorScreen(routineId: routine?.id, mode: mode, createdAt: createdAt))) as Map<String, dynamic>?;
  if (result != null) {
    final mode = result["mode"] ?? RoutineEditorMode.edit;
    final shouldClearCache = result["clearCache"] ?? false;
    if (mode == RoutineEditorMode.log) {
      if (shouldClearCache) {
        SharedPrefs().cachedRoutineLog = "";
        if (onCloseRoutineBanner != null) {
          print(result);
          onCloseRoutineBanner();
        }
      } else {
        if (onShowRoutineBanner != null) {
          onShowRoutineBanner();
        }
      }
    }
  }
}

void navigateToRoutineLogPreview({required BuildContext context, required String logId}) async {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => RoutineLogPreviewScreen(routineLogId: logId)));
}

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/Routine.dart';
import '../models/RoutineLog.dart';
import '../providers/routine_log_provider.dart';
import '../screens/editors/routine_editor_screen.dart';
import '../screens/logs/routine_log_preview_screen.dart';

void navigateToRoutineEditor({required BuildContext context, Routine? routine, RoutineLog? log, required RoutineEditorMode mode, TemporalDateTime? createdAt}) async {
  final result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => RoutineEditorScreen(routineId: routine?.id, routineLogId: log?.id, mode: mode, createdAt: createdAt))) as Map<String, bool>?;
print(result);
  if (context.mounted) {
    if (mode == RoutineEditorMode.log) {
      final shouldClearCache = result?["clear"] ?? false;
      if (shouldClearCache) {
        print(shouldClearCache);
        Provider.of<RoutineLogProvider>(context, listen: false).clearCachedLog();
      }
    }
  } else {

    print("not mounted");
  }
}

void navigateToRoutineLogPreview({required BuildContext context, required String logId}) async {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => RoutineLogPreviewScreen(routineLogId: logId)));
}

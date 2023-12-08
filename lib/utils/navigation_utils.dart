import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

import '../models/Routine.dart';
import '../models/RoutineLog.dart';
import '../screens/editors/routine_editor_screen.dart';
import '../screens/logs/routine_log_preview_screen.dart';

void navigateToRoutineEditor({required BuildContext context, Routine? routine, RoutineLog? log, required RoutineEditorMode mode, TemporalDateTime? createdAt}) async {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => RoutineEditorScreen(routineId: routine?.id, routineLogId: log?.id, mode: mode, createdAt: createdAt)));
}

void navigateToRoutineLogPreview({required BuildContext context, required String logId}) async {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => RoutineLogPreviewScreen(routineLogId: logId)));
}

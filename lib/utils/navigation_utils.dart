import 'package:flutter/material.dart';

import '../models/Routine.dart';
import '../screens/editors/routine_editor_screen.dart';
import '../routine_log_preview_screen.dart';

void navigateToRoutineEditor({required BuildContext context, Routine? routine, required RoutineEditorMode mode}) {
  Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => RoutineEditorScreen(routineId: routine?.id, mode: mode)));
}

void navigateToRoutineLogPreview({required BuildContext context, required String logId}) async {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => RoutineLogPreviewScreen(routineLogId: logId)));
}

import 'package:flutter/material.dart';
import 'package:tracker_app/models/ModelProvider.dart';

import '../screens/editors/routine_editor_screen.dart';
import '../screens/editors/routine_log_editor_screen.dart';
import '../screens/routine_log_preview_screen.dart';
import '../screens/template/routine_preview_screen.dart';

void navigateToRoutineEditor({required BuildContext context, Routine? routine}) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => RoutineEditorScreen(routine: routine)));
}

void navigateToRoutineLogEditor({required BuildContext context, required RoutineLog log}) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => RoutineLogEditorScreen(log: log)));
}

void navigateToRoutinePreview({required BuildContext context, required String routineId}) async {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => RoutinePreviewScreen(routineId: routineId)));
}

void navigateToRoutineLogPreview({required BuildContext context, required String logId}) async {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => RoutineLogPreviewScreen(routineLogId: logId)));
}

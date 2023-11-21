import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import '../../../screens/routine/logs/routine_log_preview_screen.dart';
import '../../screens/editors/routine_editor_screen.dart';

void navigateToRoutineLogPreview({required BuildContext context, required String logId}) async {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => RoutineLogPreviewScreen(routineLogId: logId)));
}

void startEmptyRoutine({required BuildContext context, TemporalDateTime? createdAt}) async {
  Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => RoutineEditorScreen(mode: RoutineEditorMode.log, createdAt: createdAt)));
}

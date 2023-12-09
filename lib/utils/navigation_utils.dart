import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

import '../models/Routine.dart';
import '../screens/editors/routine_editor_screen.dart';
import '../screens/logs/routine_log_preview_screen.dart';

Future<Map<String, dynamic>?> navigateToRoutineEditor(
    {required BuildContext context,
    Routine? routine,
    required RoutineEditorMode mode,
    TemporalDateTime? createdAt}) async {
  return await Navigator.of(context).pushNamed("/editor",
      arguments: {"routineId": routine?.id, "mode": mode, "createdAt": createdAt}) as Map<String, dynamic>?;
}

void navigateToRoutineLogPreview({required BuildContext context, required String logId}) async {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => RoutineLogPreviewScreen(routineLogId: logId)));
}

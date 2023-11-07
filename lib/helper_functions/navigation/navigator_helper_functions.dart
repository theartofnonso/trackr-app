import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/routine_log_provider.dart';
import '../../../screens/routine/logs/routine_log_preview_screen.dart';
import '../../screens/editor/routine_editor_screen.dart';

void navigateToRoutineLogPreview({required BuildContext context, required String logId}) async {
  final routineLogId = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => RoutineLogPreviewScreen(routineLogId: logId))) as String?;
  if (routineLogId != null) {
    if (context.mounted) {
      Provider.of<RoutineLogProvider>(context, listen: false).removeLogFromLocal(id: routineLogId);
    }
  }
}

void startEmptyRoutine({required BuildContext context, TemporalDateTime? createdAt}) async {
  if (context.mounted) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => RoutineEditorScreen(mode: RoutineEditorType.log, createdAt: createdAt)));
  }
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/Routine.dart';
import '../models/RoutineLog.dart';
import '../providers/routine_log_provider.dart';
import '../screens/editors/routine_editor_screen.dart';

void navigateToRoutineEditor({required BuildContext context, Routine? routine, RoutineLog? log, required RoutineEditorMode mode}) async {
  final result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => RoutineEditorScreen(routineId: routine?.id, routineLogId: log?.id, mode: mode))) as Map<String, bool>?;

  if (context.mounted) {
    if (mode == RoutineEditorMode.log) {
      final shouldClearCache = result?["clear"] ?? false;
      if (shouldClearCache) {
        Provider.of<RoutineLogProvider>(context, listen: false).clearCachedLog();
      }
    }
  }
}

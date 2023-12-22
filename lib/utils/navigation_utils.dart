import 'package:flutter/material.dart';
import 'package:tracker_app/models/ModelProvider.dart';

import '../screens/editors/routine_editor_screen.dart';
import '../screens/editors/routine_log_editor_screen.dart';
import '../screens/routine_log_preview_screen.dart';
import '../screens/routine_logs_screen.dart';
import '../screens/template/routine_preview_screen.dart';

void navigateToRoutineEditor({required BuildContext context, Routine? routine}) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => RoutineEditorScreen(routine: routine)));
}

void navigateToRoutineLogEditor({required BuildContext context, required RoutineLog log}) async {
  final createdLog = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => RoutineLogEditorScreen(log: log)));
  if(context.mounted) {
    navigateToRoutineLogPreview(context: context, log: createdLog, finishedLogging: true);
  }
}

void navigateToRoutinePreview({required BuildContext context, required String routineId}) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => RoutinePreviewScreen(routineId: routineId)));
}

void navigateToRoutineLogPreview({required BuildContext context, required RoutineLog log, bool finishedLogging = false}) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => RoutineLogPreviewScreen(log: log, finishedLogging: finishedLogging)));
}

void navigateToRoutineLogs({required BuildContext context, required List<RoutineLog> logs}) {
  final descendingLogs = logs.reversed.toList();
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => RoutineLogsScreen(logs: descendingLogs)));
}
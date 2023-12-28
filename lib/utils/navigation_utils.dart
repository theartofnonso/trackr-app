import 'package:flutter/material.dart';

import '../dtos/routine_log_dto.dart';
import '../dtos/routine_template_dto.dart';
import '../screens/editors/routine_template_editor_screen.dart';
import '../screens/editors/routine_log_editor_screen.dart';
import '../screens/routine_log_screen.dart';
import '../screens/routine_logs_screen.dart';
import '../screens/template/routine_template_screen.dart';

void navigateToRoutineEditor({required BuildContext context, RoutineTemplateDto? template}) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => RoutineTemplateEditorScreen(template: template)));
}

void navigateToRoutineLogEditor({required BuildContext context, required RoutineLogDto log}) async {
  final createdLog = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => RoutineLogEditorScreen(log: log)));
  if(context.mounted) {
    navigateToRoutineLogPreview(context: context, log: createdLog, finishedLogging: true);
  }
}

void navigateToRoutinePreview({required BuildContext context, required String templateId}) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => RoutineTemplateScreen(templateId: templateId)));
}

void navigateToRoutineLogPreview({required BuildContext context, required RoutineLogDto log, bool finishedLogging = false}) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => RoutineLogPreviewScreen(log: log, finishedLogging: finishedLogging)));
}

void navigateToRoutineLogs({required BuildContext context, required List<RoutineLogDto> logs}) {
  final descendingLogs = logs.reversed.toList();
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => RoutineLogsScreen(logs: descendingLogs)));
}
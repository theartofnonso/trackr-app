import 'package:flutter/material.dart';

import '../dtos/routine_log_dto.dart';
import '../dtos/routine_template_dto.dart';
import '../enums/routine_editor_type_enums.dart';
import '../screens/editors/routine_template_editor_screen.dart';
import '../screens/editors/routine_log_editor_screen.dart';
import '../screens/logs/routine_log_screen.dart';
import '../screens/logs/routine_logs_screen.dart';
import '../screens/template/routine_template_screen.dart';

void navigateToRoutineTemplateEditor({required BuildContext context, RoutineTemplateDto? template}) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => RoutineTemplateEditorScreen(template: template), settings: const RouteSettings(name: "RoutineTemplateEditorScreen")));
}

void navigateToRoutineLogEditor({required BuildContext context, required RoutineLogDto log, required RoutineEditorMode editorMode}) async {
  final createdLog = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => RoutineLogEditorScreen(log: log, mode: editorMode), settings: const RouteSettings(name: "RoutineLogEditorScreen"))) as RoutineLogDto?;
  if(createdLog != null) {
    if(context.mounted) {
      navigateToRoutineLogPreview(context: context, log: createdLog, finishedLogging: true);
    }
  }
}

void navigateToRoutineTemplatePreview({required BuildContext context, required RoutineTemplateDto template}) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => RoutineTemplateScreen(template: template)));
}

void navigateToRoutineLogPreview({required BuildContext context, required RoutineLogDto log, bool finishedLogging = false}) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => RoutineLogPreviewScreen(log: log, finishedLogging: finishedLogging)));
}

void navigateToRoutineLogs({required BuildContext context, required List<RoutineLogDto> logs}) {
  final descendingLogs = logs.reversed.toList();
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => RoutineLogsScreen(logs: descendingLogs)));
}
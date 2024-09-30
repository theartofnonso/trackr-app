import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker_app/dtos/viewmodels/exercise_editor_arguments.dart';
import 'package:tracker_app/dtos/viewmodels/past_routine_log_arguments.dart';
import 'package:tracker_app/screens/editors/exercise_editor_screen.dart';
import 'package:tracker_app/screens/logs/routine_log_summary_screen.dart';

import '../dtos/routine_log_dto.dart';
import '../dtos/routine_template_dto.dart';
import '../dtos/viewmodels/routine_log_arguments.dart';
import '../dtos/viewmodels/routine_template_arguments.dart';
import '../screens/editors/past_routine_log_editor_screen.dart';
import '../screens/editors/routine_log_editor_screen.dart';
import '../screens/editors/routine_template_editor_screen.dart';
import '../screens/logs/routine_log_screen.dart';
import '../screens/logs/routine_logs_screen.dart';
import '../screens/template/templates/routine_template_screen.dart';

Future<Future<Object?>> navigateToExerciseEditor(
    {required BuildContext context, ExerciseEditorArguments? arguments}) async {
  return context.push(ExerciseEditorScreen.routeName, extra: arguments);
}

Future<RoutineTemplateDto?> navigateToRoutineTemplateEditor(
    {required BuildContext context, RoutineTemplateArguments? arguments}) async {
  final template = await context.push(RoutineTemplateEditorScreen.routeName, extra: arguments) as RoutineTemplateDto?;
  return template;
}

void navigateToPastRoutineLogEditor({required BuildContext context, required PastRoutineLogArguments arguments}) {
  context.push(PastRoutineLogEditorScreen.routeName, extra: arguments);
}

Future<RoutineLogDto?> navigateToRoutineLogEditor(
    {required BuildContext context, required RoutineLogArguments arguments}) async {
  final log = await context.push(RoutineLogEditorScreen.routeName, extra: arguments) as RoutineLogDto?;
  if (log != null) {
    if (context.mounted) {
      context.push(RoutineLogScreen.routeName, extra: {"log": log, "showSummary": true});
    }
  }

  return log;
}

void navigateToRoutineTemplatePreview({required BuildContext context, required RoutineTemplateDto template}) {
  context.push(RoutineTemplateScreen.routeName, extra: template);
}

void navigateToRoutineLogPreview({required BuildContext context, required RoutineLogDto log}) {
  context.push(RoutineLogScreen.routeName, extra: {"log": log, "showSummary": false});
}

void navigateToShareableScreen({required BuildContext context, required RoutineLogDto log}) {
  context.push(RoutineLogSummaryScreen.routeName, extra: log);
}

void navigateToRoutineLogs({required BuildContext context, required List<RoutineLogDto> logs}) {
  final descendingLogs = logs.reversed.toList();
  context.push(RoutineLogsScreen.routeName, extra: descendingLogs);
}

/// Create a screen on demand
void navigateWithSlideTransition({required BuildContext context, required Widget child}) {
  final route = PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;
      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      final offsetAnimation = animation.drive(tween);
      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );

  Navigator.of(context).push(route);
}

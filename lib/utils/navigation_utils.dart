import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker_app/dtos/viewmodels/exercise_editor_arguments.dart';
import 'package:tracker_app/dtos/viewmodels/past_routine_log_arguments.dart';
import 'package:tracker_app/screens/editors/exercise_editor_screen.dart';
import 'package:tracker_app/screens/exercise/history/exercise_home_screen.dart';
import 'package:tracker_app/screens/logs/routine_log_summary_screen.dart';

import '../controllers/analytics_controller.dart';
import '../dtos/appsync/exercise_dto.dart';
import '../dtos/appsync/routine_log_dto.dart';
import '../dtos/appsync/routine_template_dto.dart';
import '../dtos/viewmodels/routine_log_arguments.dart';
import '../dtos/viewmodels/routine_template_arguments.dart';
import '../screens/editors/past_routine_log_editor_screen.dart';
import '../screens/editors/routine_log_editor_screen.dart';
import '../screens/editors/routine_template_editor_screen.dart';
import '../screens/logs/activity_logs_screen.dart';
import '../screens/logs/routine_logs_screen.dart';
import '../screens/logs/routine_log_screen.dart';
import '../screens/templates/routine_template_screen.dart';

Future<ExerciseDto?> navigateToExerciseEditor(
    {required BuildContext context, ExerciseEditorArguments? arguments}) async {
  AnalyticsController.logPageNavigation(page: ExerciseEditorScreen.routeName);
  final exercise = await context.push(ExerciseEditorScreen.routeName, extra: arguments) as ExerciseDto?;
  return exercise;
}

Future<RoutineTemplateDto?> navigateToRoutineTemplateEditor({required BuildContext context, RoutineTemplateArguments? arguments}) async {
  AnalyticsController.logPageNavigation(page: RoutineTemplateEditorScreen.routeName);
  final template = await context.push(RoutineTemplateEditorScreen.routeName, extra: arguments) as RoutineTemplateDto?;
  return template;
}

void navigateToPastRoutineLogEditor({required BuildContext context, required PastRoutineLogArguments arguments}) {
  AnalyticsController.logPageNavigation(page: PastRoutineLogEditorScreen.routeName);
  context.push(PastRoutineLogEditorScreen.routeName, extra: arguments);
}

Future<void> navigateToRoutineLogEditor({required BuildContext context, required RoutineLogArguments arguments}) async {
  AnalyticsController.logPageNavigation(page: RoutineLogEditorScreen.routeName);
  final log = await context.push(RoutineLogEditorScreen.routeName, extra: arguments) as RoutineLogDto?;
  if (log != null) {
    if (context.mounted) {
      context.push(RoutineLogScreen.routeName, extra: {"log": log, "showSummary": true, "isEditable": true});
    }
  }
}

Future<RoutineLogDto?> navigateAndEditLog(
    {required BuildContext context, required RoutineLogArguments arguments}) async {
  AnalyticsController.logPageNavigation(page: RoutineLogEditorScreen.routeName);
  final log = await context.push(RoutineLogEditorScreen.routeName, extra: arguments) as RoutineLogDto?;
  return log;
}

void navigateToRoutineTemplatePreview({required BuildContext context, required RoutineTemplateDto template}) {
  AnalyticsController.logPageNavigation(page: RoutineTemplateScreen.routeName);
  context.push(RoutineTemplateScreen.routeName, extra: template);
}

void navigateToRoutineLogPreview({required BuildContext context, required RoutineLogDto log, bool isEditable = true}) {
  AnalyticsController.logPageNavigation(page: RoutineLogScreen.routeName);
  context.push(RoutineLogScreen.routeName, extra: {"log": log, "showSummary": false, "isEditable": isEditable});
}

Future<void> navigateToExerciseHome({required BuildContext context, required ExerciseDto exercise}) async {
  AnalyticsController.logPageNavigation(page: '${ExerciseHomeScreen.routeName}: ${exercise.name}');
  await context.push(ExerciseHomeScreen.routeName, extra: exercise);
}

void navigateToShareableScreen({required BuildContext context, required RoutineLogDto log}) {
  AnalyticsController.logPageNavigation(page: RoutineLogSummaryScreen.routeName);
  context.push(RoutineLogSummaryScreen.routeName, extra: log);
}

void navigateToRoutineLogs({required BuildContext context, required DateTime dateTime}) {
  AnalyticsController.logPageNavigation(page: RoutineLogsScreen.routeName);
  context.push(RoutineLogsScreen.routeName, extra: dateTime);
}

void navigateToActivityLogs({required BuildContext context, required DateTime dateTime}) {
  AnalyticsController.logPageNavigation(page: ActivityLogsScreen.routeName);
  context.push(ActivityLogsScreen.routeName, extra: dateTime);
}

/// Create a screen on demand
Future navigateWithSlideTransition({required BuildContext context, required Widget child}) {
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

  return Navigator.of(context).push(route);
}

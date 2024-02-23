import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/viewmodels/exercise_editor_arguments.dart';
import 'package:tracker_app/screens/editors/exercise_editor_screen.dart';

import '../dtos/routine_log_dto.dart';
import '../dtos/routine_template_dto.dart';
import '../dtos/viewmodels/routine_log_arguments.dart';
import '../dtos/viewmodels/routine_template_arguments.dart';
import '../screens/editors/routine_template_editor_screen.dart';
import '../screens/editors/routine_log_editor_screen.dart';
import '../screens/logs/routine_log_screen.dart';
import '../screens/logs/routine_logs_screen.dart';
import '../screens/template/routine_template_screen.dart';

Future<Future<Object?>> navigateToExerciseEditor({required BuildContext context, ExerciseEditorArguments? arguments}) async {
  return Navigator.of(context).pushNamed(ExerciseEditorScreen.routeName, arguments: arguments);
}

void navigateToRoutineTemplateEditor({required BuildContext context, RoutineTemplateArguments? arguments}) {
  Navigator.of(context).pushNamed(RoutineTemplateEditorScreen.routeName, arguments: arguments);
}

void navigateToRoutineLogEditor({required BuildContext context, required RoutineLogArguments arguments}) async {
  final createdLog = await Navigator.of(context).pushNamed(RoutineLogEditorScreen.routeName, arguments: arguments) as RoutineLogDto?;
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
  Navigator.of(context).pushNamed(RoutineLogsScreen.routeName, arguments: descendingLogs);
}

/// Create a screen on demand
void navigateWithSlideTransition({required BuildContext context, required Widget child}) {
  final route = PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;
      final tween =
      Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      final offsetAnimation = animation.drive(tween);
      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );

  Navigator.of(context).push(route);
}

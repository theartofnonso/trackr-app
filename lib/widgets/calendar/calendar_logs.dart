import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/extensions/duration_extension.dart';

import '../../controllers/exercise_and_routine_controller.dart';
import '../routine/preview/routine_log_widget.dart';

class CalendarLogs extends StatelessWidget {
  final DateTime dateTime;

  const CalendarLogs({super.key, required this.dateTime});

  @override
  Widget build(BuildContext context) {
    /// Routine Logs
    final routineLogController = Provider.of<ExerciseAndRoutineController>(context, listen: true);
    final routineLogsForCurrentDate = routineLogController.whereLogsIsSameDay(dateTime: dateTime).toList();

    final children = routineLogsForCurrentDate.map((log) {
      Widget widget;

      widget = RoutineLogWidget(log: log, trailing: log.duration().hmsAnalog());

      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: widget,
      );
    }).toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.center, spacing: 16, children: [
      Text("Training Logs".toUpperCase(),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
      ...children
    ]);
  }
}
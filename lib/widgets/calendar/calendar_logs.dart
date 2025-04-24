import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/appsync/routine_log_dto.dart';
import 'package:tracker_app/extensions/duration_extension.dart';

import '../routine/preview/routine_log_widget.dart';

class CalendarLogs extends StatelessWidget {
  final List<RoutineLogDto> logs;

  const CalendarLogs({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    final children = logs.map((log) {
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

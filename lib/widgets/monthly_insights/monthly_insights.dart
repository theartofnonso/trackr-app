import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/widgets/monthly_insights/activities_widget.dart';
import 'package:tracker_app/widgets/monthly_insights/monthly_training_summary_widget.dart';

import '../../controllers/exercise_and_routine_controller.dart';

class MonthlyInsights extends StatelessWidget {
  final DateTimeRange dateTimeRange;

  const MonthlyInsights({super.key, required this.dateTimeRange});

  @override
  Widget build(BuildContext context) {
    final routineLogController = Provider.of<ExerciseAndRoutineController>(context, listen: true);

    /// Routine Logs
    final thisMonthRoutineLogs = routineLogController
        .whereLogsIsSameMonth(dateTime: dateTimeRange.start)
        .sorted((a, b) => b.createdAt.compareTo(a.createdAt));

    return Column(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ActivitiesWidget(dateTimeRange: dateTimeRange),
        MonthlyTrainingSummaryWidget(
          routineLogs: thisMonthRoutineLogs,
          dateTime: dateTimeRange.start,
        ),
      ],
    );
  }
}

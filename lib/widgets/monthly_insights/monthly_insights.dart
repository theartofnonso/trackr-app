import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/widgets/monthly_insights/activities_widget.dart';
import 'package:tracker_app/widgets/monthly_insights/monthly_training_summary_widget.dart';

import '../../controllers/activity_log_controller.dart';
import '../../controllers/exercise_and_routine_controller.dart';
import 'calories_widget.dart';
import 'muscle_groups_family_frequency_widget.dart';
import 'muscle_score_widget.dart';

class MonthlyInsights extends StatelessWidget {
  final DateTimeRange dateTimeRange;

  const MonthlyInsights({super.key, required this.dateTimeRange});

  @override
  Widget build(BuildContext context) {
    final routineLogController = Provider.of<ExerciseAndRoutineController>(context, listen: true);

    final activitiesController = Provider.of<ActivityLogController>(context, listen: true);

    final lastMonth = dateTimeRange.start.subtract(const Duration(days: 29));

    /// Routine Logs
    final thisMonthRoutineLogs = routineLogController
        .whereLogsIsSameMonth(dateTime: dateTimeRange.start)
        .sorted((a, b) => b.createdAt.compareTo(a.createdAt));

    final lastMonthRoutineLogs = routineLogController
        .whereLogsIsSameMonth(dateTime: lastMonth)
        .sorted((a, b) => b.createdAt.compareTo(a.createdAt));

    /// Activity Logs
    final thisMonthsActivityLogs = activitiesController
        .whereLogsIsSameMonth(dateTime: dateTimeRange.start)
        .sorted((a, b) => b.createdAt.compareTo(a.createdAt));

    final lastMonthActivityLogs = activitiesController
        .whereLogsIsSameMonth(dateTime: lastMonth)
        .sorted((a, b) => b.createdAt.compareTo(a.createdAt));

    final thisMonthLogs = [...thisMonthRoutineLogs, ...thisMonthsActivityLogs];
    final lastMonthLogs = [...lastMonthRoutineLogs, ...lastMonthActivityLogs];

    return Column(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MonthlyTrainingSummaryWidget(
          routineLogs: thisMonthRoutineLogs,
          dateTime: dateTimeRange.start,
        ),
        ActivitiesWidget(thisMonthsActivities: thisMonthsActivityLogs, lastMonthsActivities: lastMonthActivityLogs),
        if (thisMonthRoutineLogs.isNotEmpty) MuscleGroupFamilyFrequencyWidget(logs: thisMonthRoutineLogs),
        CaloriesWidget(thisMonthLogs: thisMonthLogs, lastMonthLogs: lastMonthLogs),
        MuscleScoreWidget(thisMonthLogs: thisMonthRoutineLogs, lastMonthLogs: lastMonthRoutineLogs),
      ],
    );
  }
}

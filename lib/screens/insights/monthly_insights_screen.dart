import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/widgets/monthly_insights/activities_widget.dart';
import 'package:tracker_app/widgets/monthly_insights/month_summary_widget.dart';

import '../../controllers/activity_log_controller.dart';
import '../../controllers/exercise_and_routine_controller.dart';
import '../../widgets/monthly_insights/calories_widget.dart';

class MonthlyInsightsWidget extends StatelessWidget {
  final DateTimeRange dateTimeRange;

  const MonthlyInsightsWidget({super.key, required this.dateTimeRange});

  @override
  Widget build(BuildContext context) {
    final routineLogController = Provider.of<ExerciseAndRoutineController>(context, listen: true);

    final thisMonthLogs = routineLogController
        .whereLogsIsSameMonth(dateTime: dateTimeRange.start)
        .sorted((a, b) => b.createdAt.compareTo(a.createdAt));

    final lastMonth = dateTimeRange.start.subtract(const Duration(days: 29));
    final lastMonthLogs = routineLogController
        .whereLogsIsSameMonth(dateTime: lastMonth)
        .sorted((a, b) => b.createdAt.compareTo(a.createdAt));

    final activitiesController = Provider.of<ActivityLogController>(context, listen: true);

    final activityLogs = activitiesController
        .whereLogsIsSameMonth(dateTime: dateTimeRange.start)
        .sorted((a, b) => b.createdAt.compareTo(a.createdAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TrainingSummaryWidget(
          routineLogs: thisMonthLogs,
          dateTime: dateTimeRange.start,
        ),
        const SizedBox(height: 12),
        CaloriesTrendsWidget(thisMonthLogs: thisMonthLogs, lastMonthLogs: lastMonthLogs),
        const SizedBox(height: 12),
        ActivitiesWidget(activities: activityLogs),
      ],
    );
  }
}

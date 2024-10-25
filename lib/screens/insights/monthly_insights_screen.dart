import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/widgets/monthly_insights/activities_widget.dart';
import 'package:tracker_app/widgets/monthly_insights/month_summary_widget.dart';

import '../../controllers/activity_log_controller.dart';
import '../../controllers/routine_log_controller.dart';
import '../../widgets/monthly_insights/muscle_groups_family_frequency_widget.dart';

class MonthlyInsightsScreen extends StatelessWidget {
  final DateTimeRange dateTimeRange;

  const MonthlyInsightsScreen({super.key, required this.dateTimeRange});

  @override
  Widget build(BuildContext context) {

    final routineLogController = Provider.of<RoutineLogController>(context, listen: true);

    final routineLogs = routineLogController.whereLogsIsSameMonth(dateTime: dateTimeRange.start);

    final activitiesController = Provider.of<ActivityLogController>(context, listen: true);

    final activityLogs = activitiesController.whereLogsIsSameMonth(dateTime: dateTimeRange.start);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MonthSummaryWidget(routineLogs: routineLogs, dateTime: dateTimeRange.start,),
        const SizedBox(height: 14),
        ActivitiesWidget(activities: activityLogs),
        if (routineLogs.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              MuscleGroupFamilyFrequencyWidget(logs: routineLogs),
            ],
          ),
      ],
    );
  }
}

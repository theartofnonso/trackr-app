import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/widgets/monthly_insights/activities_widget.dart';
import 'package:tracker_app/widgets/monthly_insights/log_streak_chart_widget.dart';
import 'package:tracker_app/widgets/monthly_insights/month_summary_widget.dart';

import '../../controllers/activity_log_controller.dart';
import '../../controllers/routine_log_controller.dart';
import '../../dtos/routine_log_dto.dart';
import '../../widgets/monthly_insights/muscle_group_family_frequency_chart_widget.dart';
import '../../widgets/monthly_insights/muscle_groups_family_frequency_widget.dart';

class MonthlyInsightsScreen extends StatelessWidget {
  final DateTimeRange dateTimeRange;
  final Map<DateTimeRange, List<RoutineLogDto>> monthlyLogsAndDate;
  final int daysInMonth;

  const MonthlyInsightsScreen(
      {super.key, required this.dateTimeRange, required this.monthlyLogsAndDate, required this.daysInMonth});

  @override
  Widget build(BuildContext context) {
    final routineLogController = Provider.of<RoutineLogController>(context, listen: true);

    final routineLogs = routineLogController.monthlyLogs[dateTimeRange] ?? [];

    final activitiesController = Provider.of<ActivityLogController>(context, listen: true);

    final activityLogs = activitiesController.monthlyLogs[dateTimeRange] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MonthSummaryWidget(routineLogs: routineLogs),
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
        const SizedBox(height: 24),
        MuscleGroupFamilyFrequencyChartWidget(monthlyLogs: monthlyLogsAndDate),
        const SizedBox(height: 18),
        LogStreakChartWidget(monthlyLogs: monthlyLogsAndDate),
      ],
    );
  }
}

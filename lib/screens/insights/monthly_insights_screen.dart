import 'package:flutter/material.dart';
import 'package:tracker_app/widgets/monthly_insights/activities_widget.dart';
import 'package:tracker_app/widgets/monthly_insights/month_summary_widget.dart';
import 'package:tracker_app/widgets/monthly_insights/log_streak_chart_widget.dart';

import '../../dtos/activity_log_dto.dart';
import '../../dtos/routine_log_dto.dart';
import '../../widgets/monthly_insights/muscle_group_family_frequency_chart_widget.dart';
import '../../widgets/monthly_insights/muscle_groups_family_frequency_widget.dart';

class MonthlyInsightsScreen extends StatelessWidget {
  final DateTimeRange dateTimeRange;
  final List<RoutineLogDto> logsForTheMonth;
  final List<ActivityLogDto> activityLogsForTheMonth;
  final Map<DateTimeRange, List<RoutineLogDto>> monthlyLogsAndDate;
  final int daysInMonth;

  const MonthlyInsightsScreen(
      {super.key,
      required this.dateTimeRange,
      required this.logsForTheMonth,
      required this.activityLogsForTheMonth,
      required this.monthlyLogsAndDate,
      required this.daysInMonth});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MonthSummaryWidget(routineLogs: logsForTheMonth),
        const SizedBox(height: 14),
        ActivitiesWidget(activities: activityLogsForTheMonth),
        if (logsForTheMonth.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              MuscleGroupFamilyFrequencyWidget(logs: logsForTheMonth),
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

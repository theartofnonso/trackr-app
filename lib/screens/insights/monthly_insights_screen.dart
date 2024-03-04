import 'package:flutter/material.dart';
import 'package:tracker_app/widgets/monthly_insights/exercises_sets_hours_volume_widget.dart';
import 'package:tracker_app/widgets/monthly_insights/training_and_rest_days_widget.dart';

import '../../dtos/routine_log_dto.dart';
import '../../widgets/monthly_insights/log_duration_widget.dart';
import '../../widgets/monthly_insights/muscle_group_family_frequency_chart_widget.dart';
import '../../widgets/monthly_insights/muscle_groups_family_frequency_widget.dart';

class MonthlyInsightsScreen extends StatelessWidget {
  final DateTimeRange dateTimeRange;
  final List<RoutineLogDto> logs;
  final int daysInMonth;

  const MonthlyInsightsScreen({super.key, required this.dateTimeRange, required this.logs, required this.daysInMonth});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TrainingAndRestDaysWidget(logs: logs, daysInMonth: daysInMonth, dateTimeRange: dateTimeRange,),
        const SizedBox(height: 28),
        LogDurationWidget(logs: logs),
        const SizedBox(height: 28),
        ExercisesSetsHoursVolumeWidget(logs: logs),
        const SizedBox(height: 28),
        MuscleGroupFamilyFrequencyWidget(logs: logs),
        const SizedBox(height: 16),
        const MuscleGroupFamilyFrequencyChartWidget(),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/widgets/monthly_insights/exercises_sets_hours_volume_widget.dart';
import 'package:tracker_app/widgets/monthly_insights/training_and_rest_days_widget.dart';

import '../../dtos/routine_log_dto.dart';
import '../../widgets/monthly_insights/log_duration_widget.dart';
import '../../widgets/monthly_insights/muscle_group_family_frequency_chart_widget.dart';
import '../../widgets/monthly_insights/muscle_groups_family_frequency_widget.dart';

class MonthlyInsightsScreen extends StatelessWidget {
  final List<RoutineLogDto> monthAndLogs;
  final int daysInMonth;

  const MonthlyInsightsScreen({super.key, required this.monthAndLogs, required this.daysInMonth});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LogDurationWidget(monthAndLogs: monthAndLogs),
        const SizedBox(height: 28),
        TrainingAndRestDaysWidget(monthAndLogs: monthAndLogs, daysInMonth: daysInMonth),
        const SizedBox(height: 28),
        ExercisesSetsHoursVolumeWidget(monthAndLogs: monthAndLogs),
        const SizedBox(height: 28),
        MuscleGroupFamilyFrequencyWidget(monthAndLogs: monthAndLogs),
        const SizedBox(height: 16),
        const MuscleGroupFamilyFrequencyChartWidget(),
      ],
    );
  }
}

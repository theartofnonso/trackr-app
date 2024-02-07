import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/utils/navigation_utils.dart';

import '../../dtos/routine_log_dto.dart';
import '../../utils/exercise_logs_utils.dart';
import '../../utils/general_utils.dart';
import 'streak_health_monitor.dart';
import 'muscle_group_family_frequency_monitor.dart';

class OverviewMonitor extends StatelessWidget {
  final List<RoutineLogDto> routineLogs;

  const OverviewMonitor({super.key, required this.routineLogs});

  @override
  Widget build(BuildContext context) {
    final monthlyProgress = routineLogs.length / 12;

    final exerciseLogsForTheMonth = routineLogs.expand((log) => log.exerciseLogs).toList();

    final muscleGroupsSplitFrequencyScore = muscleGroupFrequencyScore(exerciseLogs: exerciseLogsForTheMonth);

    final splitPercentage = (muscleGroupsSplitFrequencyScore * 100).toInt();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
            onTap: () => navigateToRoutineLogs(context: context, logs: routineLogs),
            child: SizedBox(
              width: 85,
              child: _MonitorScore(
                value: "${routineLogs.length}",
                title: "Streak",
                color: consistencyHealthColor(value: monthlyProgress),
                crossAxisAlignment: CrossAxisAlignment.end,
              ),
            )),
        const SizedBox(width: 20),
        Stack(alignment: Alignment.center, children: [
          StreakHealthMonitor(value: monthlyProgress),
          MuscleGroupFamilyFrequencyMonitor(value: muscleGroupsSplitFrequencyScore)
        ]),
        const SizedBox(width: 20),
        SizedBox(
          width: 85,
          child: _MonitorScore(
            value: "$splitPercentage%",
            color: Colors.white70,
            title: "Muscle",
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ),
      ],
    );
  }
}

class _MonitorScore extends StatelessWidget {
  final String value;
  final String title;
  final Color color;
  final CrossAxisAlignment crossAxisAlignment;

  const _MonitorScore(
      {required this.value, required this.title, required this.color, required this.crossAxisAlignment});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          value,
          style: GoogleFonts.montserrat(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          title.toUpperCase(),
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            color: color.withOpacity(0.9),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        )
      ],
    );
  }
}

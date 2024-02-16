import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/colors.dart';

import '../../dtos/routine_log_dto.dart';
import '../../utils/exercise_logs_utils.dart';

class MuscleGroupFamilyFrequencyMonitor extends StatelessWidget {
  final List<RoutineLogDto> routineLogs;

  const MuscleGroupFamilyFrequencyMonitor({
    Key? key,
    required this.routineLogs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final exerciseLogsForTheMonth = routineLogs.expand((log) => log.exerciseLogs).toList();

    final muscleGroupsSplitFrequencyScore = cumulativeMuscleGroupFamilyFrequencies(exerciseLogs: exerciseLogsForTheMonth);

    final splitPercentage = (muscleGroupsSplitFrequencyScore * 100).round();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5), border: Border.all(color: sapphireLighter, width: 2.0)),
      child: Row(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                LinearProgressIndicator(
                  value: muscleGroupsSplitFrequencyScore,
                  backgroundColor: sapphireDark,
                  color: Colors.white,
                  minHeight: 25,
                  borderRadius: BorderRadius.circular(3.0), // Border r
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text("MUSCLE".toUpperCase(),
                      style:
                      GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: sapphireDark, fontSize: 12)),
                )
              ],
            ),
          ),
          const SizedBox(width: 10),
            SizedBox(
                width: 32,
                child: Text("$splitPercentage%", style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12))),
        ],
      ),
    );
  }
}

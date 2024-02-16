import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/utils/general_utils.dart';

import '../../dtos/routine_log_dto.dart';

class StreakHealthMonitor extends StatelessWidget {
  final List<RoutineLogDto> routineLogs;

  const StreakHealthMonitor({
    Key? key,
    required this.routineLogs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final monthlyProgress = routineLogs.length / 12;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: sapphireDark.withOpacity(0.3),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                LinearProgressIndicator(
                  value: monthlyProgress,
                  backgroundColor: sapphireDark,
                  color: consistencyHealthColor(value: monthlyProgress),
                  minHeight: 25,
                  borderRadius: BorderRadius.circular(3.0), // Border r
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text("STREAK".toUpperCase(),
                      style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: sapphireDark, fontSize: 12)),
                )
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
              width: 32,
              child: Text("${routineLogs.length}D",
                  style: GoogleFonts.montserrat(
                      color: consistencyHealthColor(value: monthlyProgress).withOpacity(0.7), fontSize: 12))),
        ],
      ),
    );
  }
}

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/widgets/monitors/muscle_group_family_frequency_monitor.dart';

import '../../../colors.dart';
import '../../../dtos/routine_log_dto.dart';
import '../../../utils/exercise_logs_utils.dart';

class MuscleScoreLeaderBoard extends StatelessWidget {
  final Map<String, List<RoutineLogDto>> routineLogs;

  const MuscleScoreLeaderBoard({super.key, required this.routineLogs});

  @override
  Widget build(BuildContext context) {
    final sorted = routineLogs.entries.map((entry) {
      final owner = entry.key;
      final exerciseLogsForTheMonth = entry.value.expand((log) => log.exerciseLogs).toList();
      return MapEntry(owner, cumulativeMuscleGroupFamilyFrequencies(exerciseLogs: exerciseLogsForTheMonth));
    }).sorted((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
              itemBuilder: (BuildContext context, int index) => ListTile(
                  leading: MuscleGroupFamilyFrequencyMonitor(
                      value: sorted[index].value,
                      width: 25,
                      height: 25,
                      strokeWidth: 2.5,
                      strokeCap: StrokeCap.round,
                      decoration: BoxDecoration(
                        color: sapphireDark.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(100),
                      )),
                  title: Text("Anon-${sorted[index].key.split("-").first}",
                      style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600)),
                  trailing: Text("${(sorted[index].value * 100).round()}%",
                      style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w400))),
              itemCount: sorted.length),
        )
      ],
    );
  }
}

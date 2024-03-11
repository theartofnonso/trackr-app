import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
              itemBuilder: (BuildContext context, int index) => ListTile(
                  leading: Stack(alignment: Alignment.center, children: [
                    const FaIcon(FontAwesomeIcons.person, color: Colors.white, size: 25),
                    MuscleGroupFamilyFrequencyMonitor(
                        value: sorted[index].value,
                        width: 50,
                        height: 50,
                        strokeWidth: 4,
                        strokeCap: StrokeCap.round,
                        decoration: BoxDecoration(
                          color: sapphireDark.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(100),
                        ))
                  ]),
                  title: Text("Anon-${sorted[index].key.split("-").first}",
                      style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w700)),
                  subtitle: Text("${(sorted[index].value * 100).round()}%",
                      style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w400))),
              itemCount: sorted.length),
        )
      ],
    );
  }
}

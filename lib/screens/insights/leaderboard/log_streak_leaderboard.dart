import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/utils/string_utils.dart';
import 'package:tracker_app/widgets/monitors/log_streak_monitor.dart';

import '../../../colors.dart';
import '../../../dtos/routine_log_dto.dart';

class LogStreakLeaderBoard extends StatelessWidget {
  final Map<String, List<RoutineLogDto>> routineLogs;

  const LogStreakLeaderBoard({super.key, required this.routineLogs});

  @override
  Widget build(BuildContext context) {
    final sortedLogs = routineLogs.entries.toList().sorted((a, b) => b.value.length.compareTo(a.value.length));

    return Column(
      children: [
        Expanded(
            child: ListView.separated(
                itemBuilder: (BuildContext context, int index) => ListTile(
                    leading: Stack(alignment: Alignment.center, children: [
                      const FaIcon(FontAwesomeIcons.person, color: Colors.white, size: 25),
                      LogStreakMonitor(
                          value: sortedLogs[index].value.length / 12,
                          width: 50,
                          height: 50,
                          strokeWidth: 4,
                          strokeCap: StrokeCap.round,
                          decoration: BoxDecoration(
                            color: sapphireDark.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(100),
                          ))
                    ]),
                    title: Text("Anon-${sortedLogs[index].key.split("-").first}",
                        style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w700)),
                    subtitle: Text(
                        "${sortedLogs[index].value.length} ${pluralize(word: "session", count: sortedLogs[index].value.length)}",
                        style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w400))),
                itemCount: sortedLogs.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(height: 20)))
      ],
    );
  }
}

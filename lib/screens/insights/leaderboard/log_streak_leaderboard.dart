import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/utils/string_utils.dart';
import 'package:tracker_app/widgets/monitors/log_streak_monitor.dart';

import '../../../colors.dart';
import '../../../dtos/routine_log_dto.dart';

class LogStreakLeaderBoard extends StatelessWidget {
  final Map<String, List<RoutineLogDto>> routineLogs;

  const LogStreakLeaderBoard({super.key, required this.routineLogs});

  @override
  Widget build(BuildContext context) {
    final you = routineLogs.remove(SharedPrefs().userId);
    print(SharedPrefs().userId);
    final sortedLogs = routineLogs.entries.map((entry) {
      final owner = entry.key;
      return MapEntry("Anon-${owner.split("-").first}", entry.value);
    }).sorted((a, b) => b.value.length.compareTo(a.value.length));

    return Column(
      children: [
        Expanded(
            child: ListView.separated(
                itemBuilder: (BuildContext context, int index) => _ListTile(log: sortedLogs[index]),
                itemCount: sortedLogs.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(height: 20))),
        // _ListTile(log: MapEntry("You", you ?? []))
      ],
    );
  }
}

class _ListTile extends StatelessWidget {
  final MapEntry<String, List<RoutineLogDto>> log;

  const _ListTile({required this.log});

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: Stack(alignment: Alignment.center, children: [
          const FaIcon(FontAwesomeIcons.person, color: Colors.white, size: 25),
          LogStreakMonitor(
              value: log.value.length / 12,
              width: 50,
              height: 50,
              strokeWidth: 4,
              strokeCap: StrokeCap.round,
              decoration: BoxDecoration(
                color: sapphireDark.withOpacity(0.35),
                borderRadius: BorderRadius.circular(100),
              ))
        ]),
        title: Text(log.key,
            style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w700)),
        subtitle: Text("${log.value.length} ${pluralize(word: "session", count: log.value.length)}",
            style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w400)));
  }
}

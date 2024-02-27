import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../dtos/routine_log_dto.dart';
import '../../controllers/routine_log_controller.dart';
import '../../utils/general_utils.dart';
import '../../widgets/calender_heatmaps/calendar_heatmap.dart';

class StreakScreen extends StatelessWidget {

  static const routeName = '/streak_screen';

  const StreakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final routineLogController = Provider.of<RoutineLogController>(context, listen: false);

    final monthsToLogs = <MapEntry<DateTimeRange, List<RoutineLogDto>>>[];
    final ranges = monthRangesForYear(DateTime.now().year);
    for (var range in ranges) {
      final logs = routineLogController.monthlyLogs[range];
      monthsToLogs.add(
        MapEntry(range, logs ?? <RoutineLogDto>[]),
      );
    }

    final children = monthsToLogs.map((monthAndLogs) {
      final dates = monthAndLogs.value
          .map((log) => DateTime(log.createdAt.year, log.createdAt.month, log.createdAt.day))
          .toList();
      // Generate 12 containers for each month.
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: CalendarHeatMap(initialDate: monthAndLogs.key.start, dates: dates, spacing: 4, dynamicColor: true),
      );
    });

    return Scaffold(
        appBar: AppBar(
          backgroundColor: sapphireDark80,
          leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                sapphireDark80,
                sapphireDark,
              ],
            ),
          ),
          child: SafeArea(
            minimum: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Streak ${DateTime.now().year}",
                    style: GoogleFonts.montserrat(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                const SizedBox(height: 20),
                ...children
              ]),
            ),
          ),
        ));
  }
}

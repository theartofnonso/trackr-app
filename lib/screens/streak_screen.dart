import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../dtos/routine_log_dto.dart';
import '../controllers/routine_log_controller.dart';
import '../utils/general_utils.dart';
import '../widgets/backgrounds/gradient_background.dart';
import '../widgets/calender_heatmaps/calendar_heatmap.dart';

class StreakScreen extends StatelessWidget {
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

    return Scaffold(
      body: Scaffold(
          body: Stack(
            children: [
              const Positioned.fill(child: GradientBackground()),
              SafeArea(
                minimum: const EdgeInsets.all(10.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ]),
                  const SizedBox(height: 10),
                  Text("Workout Streaks ${DateTime.now().year}",
                      style: GoogleFonts.montserrat(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 3,
                      childAspectRatio: 1,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      children: List.generate(12, (index) {
                        final monthAndLogs = monthsToLogs[index];
                        final dates = monthAndLogs.value
                            .map((log) => DateTime(log.createdAt.year, log.createdAt.month, log.createdAt.day))
                            .toList();
                        // Generate 12 containers for each month.
                        return CalendarHeatMap(initialDate: monthAndLogs.key.start, dates: dates);
                      }),
                    ),
                  )
                ]),
              )
            ]
          )),
    );
  }
}

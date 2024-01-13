import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/widgets/information_container_lite.dart';

import '../dtos/routine_log_dto.dart';
import '../providers/routine_log_provider.dart';
import '../utils/general_utils.dart';
import '../widgets/backgrounds/gradient_background.dart';
import '../widgets/calender_heatmaps/calendar_heatmap.dart';

class ConsistencyScreen extends StatelessWidget {
  final int consistencyLevel;
  const ConsistencyScreen({super.key, required this.consistencyLevel});

  @override
  Widget build(BuildContext context) {
    final routineLogProvider = Provider.of<RoutineLogProvider>(context, listen: false);

    final monthsToLogs = <MapEntry<DateTimeRange, List<RoutineLogDto>>>[];
    final ranges = monthRangesForYear(DateTime.now().year);
    for (var range in ranges) {
      final logs = routineLogProvider.monthToLogs[range];
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
                  Text("Consistency Level $consistencyLevel",
                      style: GoogleFonts.montserrat(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 16),
                  const InformationContainerLite(
                    content: 'Your consistency score is determined by counting the weeks with at least one green square over a 50-week period',
                    color: tealBlueLighter,
                  ),
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

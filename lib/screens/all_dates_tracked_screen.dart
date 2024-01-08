import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/widgets/information_container_lite.dart';

import '../dtos/routine_log_dto.dart';
import '../providers/routine_log_provider.dart';
import '../utils/general_utils.dart';
import '../widgets/calender_heatmaps/calendar_heatmap.dart';

class AllDaysTrackedScreen extends StatelessWidget {
  const AllDaysTrackedScreen({super.key});

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

    // The number of containers per row is 3.
    int containersPerRow = 3;

    // Get the screen width.
    double screenWidth = MediaQuery.of(context).size.width;

    // Calculate the width of each container. Here, we subtract the padding (16.0 on each side) and
    // the spacing between the containers (8.0 between each container, hence 16.0 total for two gaps).
    double containerWidth = (screenWidth - (16.0 * 2) - (16.0 * (containersPerRow - 1))) / containersPerRow;

    // The aspect ratio for the GridView based on the container width and the screen height.
    double aspectRatio = containerWidth / (screenWidth / 3);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Scaffold(
          body: SafeArea(
        minimum: const EdgeInsets.all(10.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("All Days Trackd",
              style: GoogleFonts.montserrat(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          const InformationContainerLite(
            content: 'Green squares represent the days you have logged a training session for this year',
            color: tealBlue,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: containersPerRow,
              childAspectRatio: aspectRatio,
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
      )),
    );
  }
}

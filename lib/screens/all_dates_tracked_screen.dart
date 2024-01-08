import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../dtos/routine_log_dto.dart';
import '../providers/routine_log_provider.dart';
import '../utils/general_utils.dart';
import '../widgets/calender_heatmaps/calendar_heatmap.dart';

class AllDaysTrackedScreen extends StatelessWidget {
  const AllDaysTrackedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final routineLogProvider = Provider.of<RoutineLogProvider>(context, listen: false);

    final monthsToLogs = <DateTimeRange, List<RoutineLogDto>>{};
    final ranges = monthRangesForYear(DateTime.now().year);
    for (var range in ranges) {
      final logs = routineLogProvider.monthToLogs[range];
      monthsToLogs[range] = logs ?? <RoutineLogDto>[];
    }

    final calendarHeatmaps = monthsToLogs.map((key, value) {
      final dates = value.map((log) => DateTime(log.createdAt.year, log.createdAt.month, log.createdAt.day)).toList();
      return MapEntry(key, CalendarHeatMap(dates: dates, initialDate: key.start, margin: const EdgeInsets.all(8)));
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(minimum: const EdgeInsets.all(10.0), child: Wrap(children: calendarHeatmaps.values.toList())),
    );
  }
}

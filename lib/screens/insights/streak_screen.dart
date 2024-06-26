import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/routine_log_dto.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/extensions/routine_log_extension.dart';

import '../../colors.dart';
import '../../controllers/routine_log_controller.dart';
import '../../widgets/backgrounds/overlay_background.dart';
import '../../widgets/calendar/calendar_years_navigator.dart';
import '../../widgets/calender_heatmaps/calendar_heatmap.dart';
import '../../widgets/empty_states/calendar_heatmap_empty_state.dart';

class StreakScreen extends StatefulWidget {
  static const routeName = '/streak_screen';

  const StreakScreen({super.key});

  @override
  State<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen> {

  late DateTime _currentYear;
  List<RoutineLogDto>? _routineLogs;

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final routineLogController = Provider.of<RoutineLogController>(context, listen: true);

    final routineLogs = _routineLogs ?? routineLogController.routineLogs;

    final yearlyLogs = groupBy(routineLogs, (log) => log.createdAt.year);

    final yearsAndMonths = yearlyLogs.entries.map((yearAndLogs) {
      final monthlyLogs = groupBy(yearAndLogs.value, (log) => log.createdAt.month);
      return _YearAndMonths(year: yearAndLogs.key, monthlyLogs: monthlyLogs);
    }).toList();

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
          child: Stack(
            children: [
              SafeArea(
                minimum: const EdgeInsets.all(10.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Text("STREAK".toUpperCase(),
                      style: GoogleFonts.montserrat(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  CalendarYearsNavigator(onChangedDateTimeRange: _onChangedDateTimeRange),
                  yearsAndMonths.isEmpty
                      ? CalendarHeatMapEmptyState(dates: [_currentYear])
                      : Expanded(
                          child: ListView.separated(
                            itemCount: yearsAndMonths.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 20),
                            itemBuilder: (context, index) => yearsAndMonths[index],
                          ),
                        )
                ]),
              ),
              if (_loading) const OverlayBackground(opacity: 0.9)
            ],
          ),
        ));
  }

  void _onChangedDateTimeRange(DateTimeRange? range) {
    if (range == null) return;

    setState(() {
      _loading = true;
    });

    final routineLogController = Provider.of<RoutineLogController>(context, listen: false);

    routineLogController.fetchLogsCloud(range: range.start.dateTimeRange()).then((logs) {
      setState(() {
        _loading = false;
        _routineLogs = logs.map((log) => log.dto()).sorted((a, b) => a.createdAt.compareTo(b.createdAt));
        _currentYear = range.start;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _currentYear = DateTime.now();
  }
}

class _YearAndMonths extends StatelessWidget {
  final int year;
  final Map<int, List<RoutineLogDto>> monthlyLogs;

  const _YearAndMonths({required this.year, required this.monthlyLogs});

  @override
  Widget build(BuildContext context) {
    final monthsAndLogs = monthlyLogs.values.map((logs) {
      final dates = logs.map((log) => log.createdAt.withoutTime()).toList();
      return CalendarHeatMap(dates: dates, spacing: 4);
    }).toList();

    return Column(children: [
      GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 1,
          childAspectRatio: 1.2,
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
          children: monthsAndLogs)
    ]);
  }
}

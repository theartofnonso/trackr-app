import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/screens/muscle_distribution_screen.dart';
import 'package:tracker_app/screens/routine/template/routine_preview_screen.dart';
import 'package:tracker_app/screens/settings_screen.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import 'package:tracker_app/widgets/empty_states/screen_empty_state.dart';

import '../../dtos/graph/chart_point_dto.dart';
import '../../enums.dart';
import '../../models/RoutineLog.dart';
import '../../providers/routine_log_provider.dart';
import '../../widgets/buttons/text_button_widget.dart';
import '../../widgets/chart/line_chart_widget.dart';
import '../exercise/history/exercise_history_screen.dart';

DateTimeRange thisWeekDateRange() {
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final endOfWeek = now.add(Duration(days: 7 - now.weekday));
  return DateTimeRange(start: startOfWeek, end: endOfWeek);
}

DateTimeRange thisMonthDateRange() {
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final endOfMonth = DateTime(now.year, now.month + 1, 0);
  return DateTimeRange(start: startOfMonth, end: endOfMonth);
}

DateTimeRange thisYearDateRange() {
  final now = DateTime.now();
  final startOfYear = DateTime(now.year, 1, 1);
  final endOfYear = DateTime(now.year, 12, 31);
  return DateTimeRange(start: startOfYear, end: endOfYear);
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<RoutineLog> _logs = [];

  List<String> _dateTimes = [];

  List<ChartPointDto> _chartPoints = [];

  late ChartUnitLabel _chartUnit;

  RoutineSummaryType _summaryType = RoutineSummaryType.volume;

  CurrentTimePeriod _selectedCurrentTimePeriod = CurrentTimePeriod.allTime;

  void _navigateBack(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
    if (_summaryType == RoutineSummaryType.volume) {
      _volume();
    }
  }

  void _navigateToMuscleDistribution() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MuscleDistributionScreen()));
  }

  int _logsForTheWeekCount({required List<RoutineLog> logs}) {
    final thisWeek = thisWeekDateRange();
    return logs.where((log) => log.createdAt.getDateTimeInUtc().isBetweenRange(range: thisWeek)).toList().length;
  }

  int _logsForTheMonthCount({required List<RoutineLog> logs}) {
    final thisMonth = thisMonthDateRange();
    return logs.where((log) => log.createdAt.getDateTimeInUtc().isBetweenRange(range: thisMonth)).toList().length;
  }

  int _logsForTheYearCount({required List<RoutineLog> logs}) {
    final thisYear = thisYearDateRange();
    return logs.where((log) => log.createdAt.getDateTimeInUtc().isBetweenRange(range: thisYear)).toList().length;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RoutineLogProvider>(context, listen: true);
    final logs = provider.logs;
    final earliestLog = logs.lastOrNull;
    final logsForTheWeek = _logsForTheWeekCount(logs: logs);
    final logsForTheMonth = _logsForTheMonthCount(logs: logs);
    final logsForTheYear = _logsForTheYearCount(logs: logs);

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile", style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: false,
        actions: [
          GestureDetector(
            onTap: () => _navigateBack(context),
            child: const Padding(
              padding: EdgeInsets.only(right: 14.0),
              child: Icon(Icons.settings),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: _chartPoints.isNotEmpty
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.lato(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 15),
                            // This gets the default style
                            children: <TextSpan>[
                              const TextSpan(text: 'You have logged '),
                              TextSpan(
                                  text: '$logsForTheWeek workout(s) this week,',
                                  style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white)),
                              TextSpan(
                                  text: ' $logsForTheMonth this month',
                                  style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white)),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                  text: '$logsForTheYear this year',
                                  style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white))
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                            "${logs.length} workouts since ${earliestLog?.createdAt.getDateTimeInUtc().formattedDayAndMonthAndYear()}",
                            style: GoogleFonts.lato(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 15)),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.only(top: 20.0, right: 20, bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              DropdownButton<String>(
                                isDense: true,
                                value: _selectedCurrentTimePeriod.label,
                                underline: Container(
                                  color: Colors.transparent,
                                ),
                                style: GoogleFonts.lato(color: Colors.white),
                                onChanged: (String? value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedCurrentTimePeriod = switch (value) {
                                        "This Week" => CurrentTimePeriod.thisWeek,
                                        "This Month" => CurrentTimePeriod.thisMonth,
                                        "This Year" => CurrentTimePeriod.thisYear,
                                        _ => CurrentTimePeriod.allTime
                                      };
                                      _recomputeChart();
                                    });
                                  }
                                },
                                items: CurrentTimePeriod.values
                                    .map<DropdownMenuItem<String>>((CurrentTimePeriod currentTimePeriod) {
                                  return DropdownMenuItem<String>(
                                    value: currentTimePeriod.label,
                                    child: Text(currentTimePeriod.label, style: GoogleFonts.lato(fontSize: 12)),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),
                              LineChartWidget(
                                chartPoints: _chartPoints,
                                dateTimes: _dateTimes,
                                unit: _chartUnit,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CTextButton(
                                onPressed: _volume,
                                label: "Volume",
                                buttonColor: _buttonColor(type: RoutineSummaryType.volume)),
                            const SizedBox(width: 5),
                            CTextButton(
                                onPressed: _totalReps,
                                label: "Reps",
                                buttonColor: _buttonColor(type: RoutineSummaryType.reps)),
                            const SizedBox(width: 5),
                            CTextButton(
                                onPressed: _totalDuration,
                                label: "Duration",
                                buttonColor: _buttonColor(type: RoutineSummaryType.duration)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Theme(
                      data: ThemeData(splashColor: tealBlueLight),
                      child: ListTile(
                          onTap: () => _navigateToMuscleDistribution(),
                          tileColor: tealBlueLight,
                          dense: true,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                          title: Text("Muscle distribution", style: Theme.of(context).textTheme.labelLarge),
                          subtitle: Text("Number of sets logged for each muscle group",
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white70))),
                    ),
                  ],
                ),
              )
            : const Center(child: ScreenEmptyState(message: "Come back when you start logging workouts")),
      ),
    );
  }

  void _volume() {
    final values = _logs.map((log) => setVolumePerLog(log: log)).toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = RoutineSummaryType.volume;
      _chartUnit = weightUnit();
    });
  }

  void _totalReps() {
    final values = _logs.map((log) => repsPerLog(log: log)).toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = RoutineSummaryType.reps;
      _chartUnit = ChartUnitLabel.reps;
    });
  }

  void _totalDuration() {
    final values = _logs.map((log) => sessionDurationPerLog(log: log)).toList().toList();
    setState(() {
      _chartPoints =
          values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.inMinutes.toDouble())).toList();
      _summaryType = RoutineSummaryType.duration;
      _chartUnit = ChartUnitLabel.mins;
    });
  }

  void _recomputeChart() {
    switch (_selectedCurrentTimePeriod) {
      case CurrentTimePeriod.thisWeek:
        final thisWeek = thisWeekDateRange();
        _logs = Provider.of<RoutineLogProvider>(context, listen: false)
            .routineLogsWhereDateRange(thisWeek)
            .toList()
            .reversed
            .toList();
        break;
      case CurrentTimePeriod.thisMonth:
        final thisMonth = thisMonthDateRange();
        _logs = Provider.of<RoutineLogProvider>(context, listen: false)
            .routineLogsWhereDateRange(thisMonth)
            .toList()
            .reversed
            .toList();
        break;
      case CurrentTimePeriod.thisYear:
        final thisYear = thisYearDateRange();
        _logs = Provider.of<RoutineLogProvider>(context, listen: false)
            .routineLogsWhereDateRange(thisYear)
            .toList()
            .reversed
            .toList();
        break;
      case CurrentTimePeriod.allTime:
        _logs = Provider.of<RoutineLogProvider>(context, listen: false).logs.toList().reversed.toList();
    }

    _dateTimes = _logs.map((log) => dateTimePerLog(log: log).formattedDayAndMonth()).toList();

    switch (_summaryType) {
      case RoutineSummaryType.volume:
        _volume();
        break;
      case RoutineSummaryType.reps:
        _totalReps();
        break;
      case RoutineSummaryType.duration:
        _totalDuration();
    }
  }

  Color? _buttonColor({required RoutineSummaryType type}) {
    return _summaryType == type ? Colors.blueAccent : tealBlueLight;
  }

  void _loadChart() {
    _logs = Provider.of<RoutineLogProvider>(context, listen: false).logs.reversed.toList();
    _dateTimes = _logs.map((log) => dateTimePerLog(log: log).formattedDayAndMonth()).toList();
    _volume();
  }

  @override
  void initState() {
    super.initState();
    _loadChart();
  }
}
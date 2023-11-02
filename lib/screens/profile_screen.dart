import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/screens/routine/routine_preview_screen.dart';
import 'package:tracker_app/screens/settings_screen.dart';
import 'package:tracker_app/utils/datetime_utils.dart';

import '../dtos/graph/chart_point_dto.dart';
import '../models/RoutineLog.dart';
import '../providers/routine_log_provider.dart';
import '../widgets/buttons/text_button_widget.dart';
import '../widgets/chart/line_chart_widget.dart';
import 'exercise_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<RoutineLog> _logs = [];

  List<String> _dateTimes = [];

  List<ChartPointDto> _chartPoints = [];

  late ChartUnit _chartUnit;

  RoutineSummaryType _summaryType = RoutineSummaryType.volume;

  void _navigateTo(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
  }

  int _logsForTheWeek({required List<RoutineLog> logs}) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = now.add(Duration(days: 7 - now.weekday));
    final thisWeek = DateTimeRange(start: startOfWeek, end: endOfWeek);
    return logs.where((log) => log.createdAt.getDateTimeInUtc().isBetweenRange(range: thisWeek.endInclusive())).toList().length;
  }

  int _logsForTheMonth({required List<RoutineLog> logs}) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    final thisMonth = DateTimeRange(start: startOfMonth, end: endOfMonth);
    return logs.where((log) => log.createdAt.getDateTimeInUtc().isBetweenRange(range: thisMonth.endInclusive())).toList().length;
  }

  int _logsForTheYear({required List<RoutineLog> logs}) {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31);

    final thisYear = DateTimeRange(start: startOfYear, end: endOfYear);

    return logs.where((log) => log.createdAt.getDateTimeInUtc().isBetweenRange(range: thisYear.endInclusive())).toList().length;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RoutineLogProvider>(context);
    final logs = provider.logs;
    final earliestLog = logs.lastOrNull;
    final logsForTheWeek = _logsForTheWeek(logs: logs);
    final logsForTheMonth = _logsForTheMonth(logs: logs);
    final logsForTheYear = _logsForTheYear(logs: logs);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: tealBlueDark,
        title: const Text("Profile", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: false,
        actions: [
          GestureDetector(
            onTap: () => _navigateTo(context),
            child: const Padding(
              padding: EdgeInsets.only(right: 14.0),
              child: Icon(Icons.settings),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _chartPoints.isNotEmpty
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 15),  // This gets the default style
                            children: <TextSpan>[
                              const TextSpan(text: 'You have logged '),
                              TextSpan(text: '$logsForTheWeek workouts this week,', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                              TextSpan(text: '$logsForTheMonth this month', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                              const TextSpan(text: ' and '),
                              TextSpan(text: '$logsForTheYear this year', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white))
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text("${logs.length} workouts since ${earliestLog?.createdAt.getDateTimeInUtc().formattedDayAndMonthAndYear()}", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 15)),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0, right: 20, bottom: 10),
                          child: LineChartWidget(
                            chartPoints: _chartPoints,
                            dateTimes: _dateTimes,
                            unit: _chartUnit,
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
                    )
                  : const SizedBox.shrink(),
              const SizedBox(height: 20),
              ListTile(
                  tileColor: tealBlueLight,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                  title: Text(
                    "Sets per muscle group",
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  subtitle: Text("Number of sets logged for each muscle group",
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white70))),
              const SizedBox(height: 10),
              ListTile(
                  tileColor: tealBlueLight,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                  title: Text("Muscle distribution", style: Theme.of(context).textTheme.labelLarge),
                  subtitle: Text("See what muscles are trained freqently",
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white70)))
            ],
          ),
        ),
      ),
    );
  }

  void _volume() {
    final values = _logs.map((log) => volumePerLog(context: context, log: log)).toList();
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
      _chartUnit = ChartUnit.reps;
    });
  }

  void _totalDuration() {
    final values = _logs.map((log) => durationPerLog(log: log)).toList().toList();
    setState(() {
      _chartPoints =
          values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.inMinutes.toDouble())).toList();
      _summaryType = RoutineSummaryType.duration;
      _chartUnit = ChartUnit.min;
    });
  }

  Color? _buttonColor({required RoutineSummaryType type}) {
    return _summaryType == type ? Colors.blueAccent : tealBlueLight;
  }

  void _loadChart() {
    _logs = Provider.of<RoutineLogProvider>(context, listen: false).logs.reversed.toList();
    final values = _logs.map((log) => volumePerLog(context: context, log: log)).toList();
    _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
    _dateTimes = _logs.map((log) => dateTimePerLog(log: log).formattedDayAndMonth()).toList().reversed.toList();
  }

  @override
  void initState() {
    super.initState();

    _chartUnit = weightUnit();

    _loadChart();
  }
}

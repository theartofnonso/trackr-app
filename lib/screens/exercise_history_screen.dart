import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/providers/exercises_provider.dart';
import 'package:tracker_app/providers/routine_log_provider.dart';
import 'package:tracker_app/screens/routine_log_preview_screen.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';
import 'package:tracker_app/widgets/empty_states/screen_empty_state.dart';

import '../dtos/procedure_dto.dart';
import '../dtos/set_dto.dart';
import '../models/Exercise.dart';
import '../models/RoutineLog.dart';
import '../widgets/chart/line_chart_widget.dart';
import '../widgets/routine/preview/routine_log_lite_widget.dart';
import '../dtos/graph/chart_point_dto.dart';

const exerciseRouteName = "/exercise-history-screen";

List<SetDto> _allSets({required BuildContext context, required List<String> procedureJsons}) {
  final procedures = procedureJsons.map((json) => ProcedureDto.fromJson(jsonDecode(json))).toList();
  List<SetDto> completedSets = [];
  for (var procedure in procedures) {
    completedSets.addAll(procedure.sets);
  }
  return completedSets;
}

/// Highest value per [RoutineLogDto]

SetDto _heaviestWeightInSetPerLog({required BuildContext context, required RoutineLog log}) {
  int heaviestWeight = 0;
  SetDto setWithHeaviestWeight = SetDto();

  final sets = _allSets(context: context, procedureJsons: log.procedures);

  for (var set in sets) {
    final weight = set.weight;
    if (weight > heaviestWeight) {
      heaviestWeight = weight;
      setWithHeaviestWeight = set;
    }
  }
  return setWithHeaviestWeight;
}

int _heaviestWeightPerLog({required BuildContext context, required RoutineLog log}) {
  int heaviestWeight = 0;

  final sets = _allSets(context: context, procedureJsons: log.procedures);

  for (var set in sets) {
    final weight = set.weight;
    if (weight > heaviestWeight) {
      heaviestWeight = weight;
    }
  }
  return heaviestWeight;
}

int _repsPerLog({required BuildContext context, required RoutineLog log}) {
  int totalReps = 0;

  final sets = _allSets(context: context, procedureJsons: log.procedures);

  for (var set in sets) {
    final weight = set.rep;
    totalReps += weight;
  }
  return totalReps;
}

int _heaviestSetVolumePerLog({required BuildContext context, required RoutineLog log}) {
  int heaviestVolume = 0;

  final sets = _allSets(context: context, procedureJsons: log.procedures);

  for (var set in sets) {
    final volume = set.rep * set.weight;
    if (volume > heaviestVolume) {
      heaviestVolume = volume;
    }
  }
  return heaviestVolume;
}

int _volumePerLog({required BuildContext context, required RoutineLog log}) {
  int totalVolume = 0;

  final sets = _allSets(context: context, procedureJsons: log.procedures);

  for (var set in sets) {
    final volume = set.rep * set.weight;
    totalVolume += volume;
  }
  return totalVolume;
}

double _oneRepMaxPerLog({required BuildContext context, required RoutineLog log}) {
  final heaviestWeightInSet = _heaviestWeightInSetPerLog(context: context, log: log);

  return (heaviestWeightInSet.weight * (1 + 0.0333 * heaviestWeightInSet.rep));
}

DateTime _dateTimePerLog({required RoutineLog log}) {
  return log.endTime.getDateTimeInUtc();
}

int _totalVolumePerLog({required BuildContext context, required RoutineLog log}) {
  int totalVolume = 0;

  final sets = _allSets(context: context, procedureJsons: log.procedures);

  for (var set in sets) {
    final volume = set.rep * set.weight;
    totalVolume += volume;
  }
  return totalVolume;
}

/// Highest value across all [RoutineLogDto]

(String, SetDto) _heaviestSet({required BuildContext context, required List<RoutineLog> logs}) {
  SetDto heaviestSet = SetDto();
  String logId = "";
  for (var log in logs) {
    final sets = _allSets(context: context, procedureJsons: log.procedures);
    for (var set in sets) {
      final volume = set.rep * set.weight;
      if (volume > (heaviestSet.rep * heaviestSet.weight)) {
        heaviestSet = set;
        logId = log.id;
      }
    }
  }
  return (logId, heaviestSet);
}

(String, int) _heaviestLogVolume({required BuildContext context, required List<RoutineLog> logs}) {
  int heaviestVolume = 0;
  String logId = "";
  for (var log in logs) {
    final totalVolume = _totalVolumePerLog(context: context, log: log);
    if (totalVolume > heaviestVolume) {
      heaviestVolume = totalVolume;
      logId = log.id;
    }
  }

  return (logId, heaviestVolume);
}

(String, int) _heaviestWeight({required BuildContext context, required List<RoutineLog> logs}) {
  int heaviestWeight = 0;
  String logId = "";
  for (var log in logs) {
    final sets = _allSets(context: context, procedureJsons: log.procedures);
    for (var set in sets) {
      final weight = set.weight;
      if (weight > heaviestWeight) {
        heaviestWeight = weight;
        logId = log.id;
      }
    }
  }
  return (logId, heaviestWeight);
}

class ExerciseHistoryScreen extends StatelessWidget {
  final String exerciseId;

  const ExerciseHistoryScreen({super.key, required this.exerciseId});

  List<RoutineLog> _whereLogsForExercise({required BuildContext context, required List<RoutineLog> logs}) {
    return logs
        .where((log) => log.procedures
            .map((json) => ProcedureDto.fromJson(jsonDecode(json)))
            .any((procedure) => procedure.exerciseId == exerciseId))
        .map((log) => log.copyWith(
            procedures: log.procedures
                .where((procedure) => ProcedureDto.fromJson(jsonDecode(procedure)).exerciseId == exerciseId)
                .toList()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final exercise = Provider.of<ExerciseProvider>(context, listen: false).whereExercise(exerciseId: exerciseId);

    final routineLogs = Provider.of<RoutineLogProvider>(context, listen: false).logs;

    final routineLogsForExercise = _whereLogsForExercise(context: context, logs: routineLogs);

    final heaviestRoutineLogVolume = _heaviestLogVolume(context: context, logs: routineLogsForExercise);

    final heaviestSet = _heaviestSet(context: context, logs: routineLogsForExercise);

    final heaviestWeight = _heaviestWeight(context: context, logs: routineLogsForExercise);

    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: Text(exercise.name,
                  style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
              bottom: const TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(
                    text: "Summary",
                  ),
                  Tab(
                    text: "History",
                  )
                ],
              )),
          body: TabBarView(
            children: [
              SummaryWidget(
                heaviestWeight: heaviestWeight,
                heaviestSet: heaviestSet,
                heaviestRoutineLogVolume: heaviestRoutineLogVolume,
                routineLogs: routineLogsForExercise,
                exercise: exercise,
              ),
              HistoryWidget(logs: routineLogsForExercise)
            ],
          ),
        ));
  }
}

class SummaryWidget extends StatefulWidget {
  final (String, int) heaviestWeight;
  final (String, SetDto) heaviestSet;
  final (String, int) heaviestRoutineLogVolume;
  final List<RoutineLog> routineLogs;
  final Exercise exercise;

  const SummaryWidget(
      {super.key,
      required this.heaviestWeight,
      required this.heaviestSet,
      required this.routineLogs,
      required this.heaviestRoutineLogVolume,
      required this.exercise});

  @override
  State<SummaryWidget> createState() => _SummaryWidgetState();
}

enum SummaryType { heaviestWeights, heaviestSetVolumes, logVolumes, oneRepMaxes, reps }

class _SummaryWidgetState extends State<SummaryWidget> {
  List<String> _dateTimes = [];

  List<ChartPointDto> _chartPoints = [];

  SummaryType _summaryType = SummaryType.heaviestWeights;

  void _heaviestWeights() {
    final values =
        widget.routineLogs.map((log) => _heaviestWeightPerLog(context: context, log: log)).toList().reversed.toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = SummaryType.heaviestWeights;
    });
  }

  void _heaviestSetVolumes() {
    final values = widget.routineLogs
        .map((log) => _heaviestSetVolumePerLog(context: context, log: log))
        .toList()
        .reversed
        .toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = SummaryType.heaviestSetVolumes;
    });
  }

  void _logVolumes() {
    final values =
        widget.routineLogs.map((log) => _volumePerLog(context: context, log: log)).toList().reversed.toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = SummaryType.logVolumes;
    });
  }

  void _oneRepMaxes() {
    final values =
        widget.routineLogs.map((log) => _oneRepMaxPerLog(context: context, log: log)).toList().reversed.toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = SummaryType.oneRepMaxes;
    });
  }

  void _reps() {
    final values = widget.routineLogs.map((log) => _repsPerLog(context: context, log: log)).toList().reversed.toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = SummaryType.reps;
    });
  }

  Color? _buttonColor({required SummaryType type}) {
    return _summaryType == type ? Colors.blueAccent : null;
  }

  void _navigateTo({required String routineLogId}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            RoutineLogPreviewScreen(routineLogId: routineLogId, previousRouteName: exerciseRouteName)));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.routineLogs.isNotEmpty) {
      final oneRepMax = widget.routineLogs.map((log) => _oneRepMaxPerLog(context: context, log: log)).toList().max;
      return SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const SizedBox(height: 10),
            // Text(
            //   "Primary Target: ${exercise.primary.join(", ")}",
            //   style: TextStyle(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500, fontSize: 12),
            // ),
            // const SizedBox(height: 5),
            // Text(
            //   "Secondary Target: ${exercise.secondary.isNotEmpty ? exercise.secondary.join(", ") : "None"}",
            //   style: TextStyle(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500, fontSize: 12),
            // ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(top: 20.0, right: 30, bottom: 20),
              child: LineChartWidget(chartPoints: _chartPoints, dateTimes: _dateTimes),
            ),
            SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    CTextButton(
                        onPressed: _heaviestWeights,
                        label: "Heaviest Weight",
                        buttonColor: _buttonColor(type: SummaryType.heaviestWeights)),
                    const SizedBox(width: 5),
                    CTextButton(
                        onPressed: _heaviestSetVolumes,
                        label: "Heaviest Set Volume",
                        buttonColor: _buttonColor(type: SummaryType.heaviestSetVolumes)),
                    const SizedBox(width: 5),
                    CTextButton(
                        onPressed: _logVolumes,
                        label: "Session Volume",
                        buttonColor: _buttonColor(type: SummaryType.logVolumes)),
                    const SizedBox(width: 5),
                    CTextButton(
                        onPressed: _oneRepMaxes,
                        label: "1RM",
                        buttonColor: _buttonColor(type: SummaryType.oneRepMaxes)),
                    const SizedBox(width: 5),
                    CTextButton(
                        onPressed: _reps, label: "Total Reps", buttonColor: _buttonColor(type: SummaryType.reps)),
                  ],
                )),
            const SizedBox(height: 10),
            MetricWidget(
              title: 'Heaviest weight',
              summary: "${widget.heaviestWeight.$2}kg",
              subtitle: 'Heaviest weight lifted for a set',
              onTap: () => _navigateTo(routineLogId: widget.heaviestWeight.$1),
            ),
            const SizedBox(height: 10),
            MetricWidget(
              title: 'Heaviest Set Volume',
              summary: "${widget.heaviestSet.$2.weight}kg x ${widget.heaviestSet.$2.rep}",
              subtitle: 'Heaviest volume lifted for a set',
              onTap: () => _navigateTo(routineLogId: widget.heaviestSet.$1),
            ),
            const SizedBox(height: 10),
            MetricWidget(
              title: 'Heaviest Session Volume',
              summary: "${widget.heaviestRoutineLogVolume.$2}kg",
              subtitle: 'Heaviest volume lifted for a session',
              onTap: () => _navigateTo(routineLogId: widget.heaviestRoutineLogVolume.$1),
            ),
            const SizedBox(height: 10),
            MetricWidget(
              title: '1 Rep Max',
              summary: '${oneRepMax}kg',
              subtitle: 'Heaviest weight you can lift for one rep',
              onTap: () => _navigateTo(routineLogId: widget.heaviestWeight.$1),
            ),
          ],
        ),
      ));
    }
    return const Center(child: ScreenEmptyState(message: "Start logging workouts to generate data"));
  }

  @override
  void initState() {
    super.initState();
    final values =
        widget.routineLogs.map((log) => _heaviestWeightPerLog(context: context, log: log)).toList().reversed.toList();
    _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();

    _dateTimes =
        widget.routineLogs.map((log) => _dateTimePerLog(log: log).formattedDayAndMonth()).toList().reversed.toList();
  }
}

class HistoryWidget extends StatelessWidget {
  final List<RoutineLog> logs;

  const HistoryWidget({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    return logs.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.separated(
                      itemBuilder: (BuildContext context, int index) => RoutineLogLiteWidget(
                            routineLog: logs[index],
                          ),
                      separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 18),
                      itemCount: logs.length),
                ),
              ],
            ),
          )
        : const Center(child: ScreenEmptyState(message: "Start logging workouts to generate data"));
  }
}

class MetricWidget extends StatelessWidget {
  const MetricWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.summary,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String summary;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(splashColor: tealBlueLight),
      child: ListTile(
        onTap: onTap,
        tileColor: tealBlueLight,
        title: Text(title, style: const TextStyle(fontSize: 14, color: Colors.white)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7))),
        trailing: Text(summary, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      ),
    );
  }
}

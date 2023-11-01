import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/providers/exercise_provider.dart';
import 'package:tracker_app/providers/routine_log_provider.dart';
import 'package:tracker_app/screens/logs/routine_log_preview_screen.dart';
import 'package:tracker_app/screens/settings_screen.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';
import 'package:tracker_app/widgets/empty_states/screen_empty_state.dart';

import '../dtos/procedure_dto.dart';
import '../dtos/set_dto.dart';
import '../models/Exercise.dart';
import '../models/RoutineLog.dart';
import '../providers/weight_unit_provider.dart';
import '../shared_prefs.dart';
import '../utils/general_utils.dart';
import '../widgets/chart/line_chart_widget.dart';
import '../widgets/exercise_history/routine_log_widget.dart';
import '../dtos/graph/chart_point_dto.dart';

const exerciseRouteName = "/exercise-history-screen";

ChartUnit weightUnit() {
  return SharedPrefs().weightUnit == WeightUnit.kg.name ? ChartUnit.kg : ChartUnit.lbs;
}

List<SetDto> _allSets({required List<String> procedureJsons}) {
  final procedures = procedureJsons.map((json) => ProcedureDto.fromJson(jsonDecode(json))).toList();
  List<SetDto> completedSets = [];
  for (var procedure in procedures) {
    completedSets.addAll(procedure.sets);
  }
  return completedSets;
}

/// Highest value per [RoutineLogDto]

SetDto _heaviestWeightInSetPerLog({required RoutineLog log}) {
  double heaviestWeight = 0;
  SetDto setWithHeaviestWeight = SetDto();

  final sets = _allSets(procedureJsons: log.procedures);

  for (var set in sets) {
    final weight = set.weight;
    if (weight > heaviestWeight) {
      heaviestWeight = weight;
      setWithHeaviestWeight = set;
    }
  }
  return setWithHeaviestWeight;
}

double _heaviestWeightPerLog({required BuildContext context, required RoutineLog log}) {
  double heaviestWeight = 0;

  final sets = _allSets(procedureJsons: log.procedures);

  for (var set in sets) {
    final weight = set.weight;
    if (weight > heaviestWeight) {
      heaviestWeight = weight;
    }
  }

  final weightProvider = Provider.of<WeightUnitProvider>(context, listen: false);
  final conversion = weightProvider.isLbs ? toLbs(heaviestWeight) : heaviestWeight;

  return conversion;
}

int repsPerLog({required RoutineLog log}) {
  int totalReps = 0;

  final sets = _allSets(procedureJsons: log.procedures);

  for (var set in sets) {
    final reps = set.reps;
    totalReps += reps;
  }
  return totalReps;
}

double _heaviestSetVolumePerLog({required BuildContext context, required RoutineLog log}) {
  double heaviestVolume = 0;

  final sets = _allSets(procedureJsons: log.procedures);

  for (var set in sets) {
    final volume = set.reps * set.weight;
    if (volume > heaviestVolume) {
      heaviestVolume = volume;
    }
  }

  final weightProvider = Provider.of<WeightUnitProvider>(context, listen: false);
  final conversion = weightProvider.isLbs ? toLbs(heaviestVolume) : heaviestVolume;

  return conversion;
}

double volumePerLog({required BuildContext context, required RoutineLog log}) {
  double totalVolume = 0;

  final sets = _allSets(procedureJsons: log.procedures);

  for (var set in sets) {
    final volume = set.reps * set.weight;
    totalVolume += volume;
  }

  final weightProvider = Provider.of<WeightUnitProvider>(context, listen: false);
  final conversion = weightProvider.isLbs ? toLbs(totalVolume) : totalVolume;

  return conversion;
}

double _oneRepMaxPerLog({required BuildContext context, required RoutineLog log}) {
  final heaviestWeightInSet = _heaviestWeightInSetPerLog(log: log);

  final max = (heaviestWeightInSet.weight * (1 + 0.0333 * heaviestWeightInSet.reps));

  final weightProvider = Provider.of<WeightUnitProvider>(context, listen: false);
  final conversion = weightProvider.isLbs ? toLbs(max) : max;

  return conversion;
}

DateTime dateTimePerLog({required RoutineLog log}) {
  return log.endTime.getDateTimeInUtc();
}

Duration durationPerLog({required RoutineLog log}) {
  final startTime = log.startTime.getDateTimeInUtc();
  final endTime = log.endTime.getDateTimeInUtc();
  final difference = endTime.difference(startTime);
  return difference;
}

double _totalVolumePerLog({required BuildContext context, required RoutineLog log}) {
  double totalVolume = 0;

  final sets = _allSets(procedureJsons: log.procedures);

  for (var set in sets) {
    final volume = set.reps * set.weight;
    totalVolume += volume;
  }

  final weightProvider = Provider.of<WeightUnitProvider>(context, listen: false);
  final conversion = weightProvider.isLbs ? toLbs(totalVolume) : totalVolume;

  return conversion;
}

/// Highest value across all [RoutineLogDto]

(String, SetDto) _heaviestSet({required BuildContext context, required List<RoutineLog> logs}) {
  SetDto heaviestSet = SetDto();
  String logId = "";
  for (var log in logs) {
    final sets = _allSets(procedureJsons: log.procedures);
    for (var set in sets) {
      final volume = set.reps * set.weight;
      if (volume > (heaviestSet.reps * heaviestSet.weight)) {
        heaviestSet = set;
        logId = log.id;
      }
    }
  }

  final weightProvider = Provider.of<WeightUnitProvider>(context, listen: false);
  final conversion = weightProvider.isLbs ? toLbs(heaviestSet.weight) : heaviestSet.weight;

  return (logId, heaviestSet.copyWith(weight: conversion));
}

(String, double) _heaviestLogVolume({required BuildContext context, required List<RoutineLog> logs}) {
  double heaviestVolume = 0;
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

(String, double) _heaviestWeight({required BuildContext context, required List<RoutineLog> logs}) {
  double heaviestWeight = 0;
  String logId = "";
  for (var log in logs) {
    final weight = _heaviestWeightPerLog(context: context, log: log);
    if (weight > heaviestWeight) {
      heaviestWeight = weight;
      logId = log.id;
    }
  }
  return (logId, heaviestWeight);
}

class ExerciseHistoryScreen extends StatelessWidget {
  final String exerciseId;

  const ExerciseHistoryScreen({super.key, required this.exerciseId});

  List<RoutineLog> _logsWhereExercise({required List<RoutineLog> logs}) {
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
    final exercise = Provider.of<ExerciseProvider>(context, listen: true).whereExercise(exerciseId: exerciseId);

    final routineLogs = Provider.of<RoutineLogProvider>(context, listen: true).logs;

    final routineLogsForExercise = _logsWhereExercise(logs: routineLogs);

    final heaviestRoutineLogVolume = _heaviestLogVolume(context: context, logs: routineLogsForExercise);

    final heaviestSet = _heaviestSet(context: context, logs: routineLogsForExercise);

    final heaviestWeight = _heaviestWeight(context: context, logs: routineLogsForExercise);

    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
              backgroundColor: tealBlueDark,
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
  final (String, double) heaviestWeight;
  final (String, SetDto) heaviestSet;
  final (String, double) heaviestRoutineLogVolume;
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

  late ChartUnit _chartUnit;

  SummaryType _summaryType = SummaryType.heaviestWeights;

  void _heaviestWeights() {
    final values =
        widget.routineLogs.map((log) => _heaviestWeightPerLog(context: context, log: log)).toList().reversed.toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = SummaryType.heaviestWeights;
      _chartUnit = weightUnit();
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
      _chartUnit = weightUnit();
    });
  }

  void _logVolumes() {
    final values = widget.routineLogs.map((log) => volumePerLog(context: context, log: log)).toList().reversed.toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = SummaryType.logVolumes;
      _chartUnit = weightUnit();
    });
  }

  void _oneRepMaxes() {
    final values =
        widget.routineLogs.map((log) => _oneRepMaxPerLog(context: context, log: log)).toList().reversed.toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = SummaryType.oneRepMaxes;
      _chartUnit = weightUnit();
    });
  }

  void _reps() {
    final values = widget.routineLogs.map((log) => repsPerLog(log: log)).toList().reversed.toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = SummaryType.reps;
      _chartUnit = ChartUnit.reps;
    });
  }

  Color? _buttonColor({required SummaryType type}) {
    return _summaryType == type ? Colors.blueAccent : tealBlueLight;
  }

  void _navigateTo({required String routineLogId}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            RoutineLogPreviewScreen(routineLogId: routineLogId, previousRouteName: exerciseRouteName)));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.routineLogs.isNotEmpty) {

      final weightUnitLabel = weightLabel();

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
              padding: const EdgeInsets.only(top: 20.0, right: 20, bottom: 20),
              child: LineChartWidget(
                chartPoints: _chartPoints,
                dateTimes: _dateTimes,
                unit: _chartUnit,
              ),
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
              summary: "${widget.heaviestWeight.$2}$weightUnitLabel",
              subtitle: 'Heaviest weight lifted for a set',
              onTap: () => _navigateTo(routineLogId: widget.heaviestWeight.$1),
            ),
            const SizedBox(height: 10),
            MetricWidget(
              title: 'Heaviest Set Volume',
              summary: "${widget.heaviestSet.$2.weight}$weightUnitLabel x ${widget.heaviestSet.$2.reps}",
              subtitle: 'Heaviest volume lifted for a set',
              onTap: () => _navigateTo(routineLogId: widget.heaviestSet.$1),
            ),
            const SizedBox(height: 10),
            MetricWidget(
              title: 'Heaviest Session Volume',
              summary: "${widget.heaviestRoutineLogVolume.$2}$weightUnitLabel",
              subtitle: 'Heaviest volume lifted for a session',
              onTap: () => _navigateTo(routineLogId: widget.heaviestRoutineLogVolume.$1),
            ),
            const SizedBox(height: 10),
            MetricWidget(
              title: '1 Rep Max',
              summary: '${oneRepMax.toStringAsFixed(2)}$weightUnitLabel',
              subtitle: 'Heaviest weight for one rep',
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

    _chartUnit = weightUnit();

    final values =
        widget.routineLogs.map((log) => _heaviestWeightPerLog(context: context, log: log)).toList().reversed.toList();
    _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();

    _dateTimes =
        widget.routineLogs.map((log) => dateTimePerLog(log: log).formattedDayAndMonth()).toList().reversed.toList();
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
                      itemBuilder: (BuildContext context, int index) => RoutineLogWidget(
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

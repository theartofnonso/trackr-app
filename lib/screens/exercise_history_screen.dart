import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/dtos/routine_log_dto.dart';
import 'package:tracker_app/providers/exercises_provider.dart';
import 'package:tracker_app/providers/routine_log_provider.dart';
import 'package:tracker_app/screens/routine_log_preview_screen.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';

import '../dtos/procedure_dto.dart';
import '../dtos/set_dto.dart';
import '../models/Exercise.dart';
import '../widgets/chart/line_chart_widget.dart';
import '../widgets/routine/preview/routine_log_lite_widget.dart';
import '../dtos/graph/chart_point_dto.dart';

const exerciseRouteName = "/exercise-history-screen";

List<SetDto> _allSets({required List<ProcedureDto> procedures}) {
  List<SetDto> completedSets = [];
  for (var procedure in procedures) {
    completedSets.addAll(procedure.sets);
  }
  return completedSets;
}

/// Highest value per [RoutineLogDto]

SetDto _heaviestWeightInSetPerLog({required RoutineLogDto log}) {
  int heaviestWeight = 0;
  SetDto setWithHeaviestWeight = SetDto();

  final sets = _allSets(procedures: log.procedures);
  for (var set in sets) {
    final weight = set.weight;
    if (weight > heaviestWeight) {
      heaviestWeight = weight;
      setWithHeaviestWeight = set;
    }
  }
  return setWithHeaviestWeight;
}

int _heaviestWeightPerLog({required RoutineLogDto log}) {
  int heaviestWeight = 0;

  final sets = _allSets(procedures: log.procedures);

  for (var set in sets) {
    final weight = set.weight;
    if (weight > heaviestWeight) {
      heaviestWeight = weight;
    }
  }
  return heaviestWeight;
}

int _repsPerLog({required RoutineLogDto log}) {
  int totalReps = 0;

  final sets = _allSets(procedures: log.procedures);

  for (var set in sets) {
    final weight = set.rep;
    totalReps += weight;
  }
  return totalReps;
}

int _heaviestSetVolumePerLog({required RoutineLogDto log}) {
  int heaviestVolume = 0;

  final sets = _allSets(procedures: log.procedures);

  for (var set in sets) {
    final volume = set.rep * set.weight;
    if (volume > heaviestVolume) {
      heaviestVolume = volume;
    }
  }
  return heaviestVolume;
}

int _volumePerLog({required RoutineLogDto log}) {
  int totalVolume = 0;

  final sets = _allSets(procedures: log.procedures);

  for (var set in sets) {
    final volume = set.rep * set.weight;
    totalVolume += volume;
  }
  return totalVolume;
}

double _oneRepMaxPerLog({required RoutineLogDto log}) {
  final heaviestWeightInSet = _heaviestWeightInSetPerLog(log: log);

  return (heaviestWeightInSet.weight * (1 + 0.0333 * heaviestWeightInSet.rep));
}

DateTime _dateTimePerLog({required RoutineLogDto log}) {
  return log.endTime!;
}

int _totalVolumePerLog({required RoutineLogDto log}) {
  int totalVolume = 0;

  final sets = _allSets(procedures: log.procedures);

  for (var set in sets) {
    final volume = set.rep * set.weight;
    totalVolume += volume;
  }
  return totalVolume;
}

/// Highest value across all [RoutineLogDto]

(String, SetDto) _heaviestSet({required List<RoutineLogDto> logs}) {
  SetDto heaviestSet = SetDto();
  String logId = "";
  for (var log in logs) {
    final sets = _allSets(procedures: log.procedures);
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

(String, int) _heaviestLogVolume({required List<RoutineLogDto> logs}) {
  int heaviestVolume = 0;
  String logId = "";
  for (var log in logs) {
    final totalVolume = _totalVolumePerLog(log: log);
    if (totalVolume > heaviestVolume) {
      heaviestVolume = totalVolume;
      logId = log.id;
    }
  }

  return (logId, heaviestVolume);
}

(String, int) _heaviestWeight({required List<RoutineLogDto> logs}) {
  int heaviestWeight = 0;
  String logId = "";
  for (var log in logs) {
    final sets = _allSets(procedures: log.procedures);
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

  List<RoutineLogDto> _whereLogsForExercise({required List<RoutineLogDto> logs}) {
    return logs
        .where((log) => log.procedures.any((procedure) => procedure.exercise.id == exerciseId))
        .map((log) =>
            log.copyWith(procedures: log.procedures.where((procedure) => procedure.exercise.id == exerciseId).toList()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final exercise = Provider.of<ExerciseProvider>(context, listen: false).whereExercise(exerciseId: exerciseId);

    final routineLogs = Provider.of<RoutineLogProvider>(context, listen: false).logs;

    final routineLogsForExercise = _whereLogsForExercise(logs: routineLogs);

    final heaviestRoutineLogVolume = _heaviestLogVolume(logs: routineLogsForExercise);

    final heaviestSet = _heaviestSet(logs: routineLogsForExercise);

    final heaviestWeight = _heaviestWeight(logs: routineLogsForExercise);

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
                routineLogDtos: routineLogsForExercise,
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
  final List<RoutineLogDto> routineLogDtos;
  final Exercise exercise;

  const SummaryWidget(
      {super.key,
      required this.heaviestWeight,
      required this.heaviestSet,
      required this.routineLogDtos,
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
    final values = widget.routineLogDtos.map((log) => _heaviestWeightPerLog(log: log)).toList().reversed.toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = SummaryType.heaviestWeights;
    });
  }

  void _heaviestSetVolumes() {
    final values = widget.routineLogDtos.map((log) => _heaviestSetVolumePerLog(log: log)).toList().reversed.toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = SummaryType.heaviestSetVolumes;
    });
  }

  void _logVolumes() {
    final values = widget.routineLogDtos.map((log) => _volumePerLog(log: log)).toList().reversed.toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = SummaryType.logVolumes;
    });
  }

  void _oneRepMaxes() {
    final values = widget.routineLogDtos.map((log) => _oneRepMaxPerLog(log: log)).toList().reversed.toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = SummaryType.oneRepMaxes;
    });
  }

  void _reps() {
    final values = widget.routineLogDtos.map((log) => _repsPerLog(log: log)).toList().reversed.toList();
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
    final oneRepMax = widget.routineLogDtos.map((log) => _oneRepMaxPerLog(log: log)).toList().max;

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
                  CTextButton(onPressed: _heaviestSetVolumes, label: "Heaviest Set Volume", buttonColor: _buttonColor(type: SummaryType.heaviestSetVolumes)),
                  const SizedBox(width: 5),
                  CTextButton(onPressed: _logVolumes, label: "Session Volume", buttonColor: _buttonColor(type: SummaryType.logVolumes)),
                  const SizedBox(width: 5),
                  CTextButton(onPressed: _oneRepMaxes, label: "1RM", buttonColor: _buttonColor(type: SummaryType.oneRepMaxes)),
                  const SizedBox(width: 5),
                  CTextButton(onPressed: _reps, label: "Total Reps", buttonColor: _buttonColor(type: SummaryType.reps)),
                ],
              )),
          const SizedBox(height: 10),
          MetricWidget(
              title: 'Heaviest weight',
              summary: "${widget.heaviestWeight.$2}kg",
              subtitle: 'Heaviest weight lifted for a set', onTap: () => _navigateTo(routineLogId: widget.heaviestWeight.$1),),
          const SizedBox(height: 10),
          MetricWidget(
            title: 'Heaviest Set Volume',
            summary: "${widget.heaviestSet.$2.weight}kg x ${widget.heaviestSet.$2.rep}",
            subtitle: 'Heaviest volume lifted for a set', onTap: () => _navigateTo(routineLogId: widget.heaviestSet.$1),
          ),
          const SizedBox(height: 10),
          MetricWidget(
            title: 'Heaviest Session Volume',
            summary: "${widget.heaviestRoutineLogVolume.$2}kg",
            subtitle: 'Heaviest volume lifted for a session', onTap: () => _navigateTo(routineLogId: widget.heaviestRoutineLogVolume.$1),
          ),
          const SizedBox(height: 10),
          MetricWidget(
            title: '1 Rep Max',
            summary: '${oneRepMax}kg',
            subtitle: 'Heaviest weight you can lift for one rep', onTap: () => _navigateTo(routineLogId: widget.heaviestWeight.$1),
          ),
        ],
      ),
    ));
  }

  @override
  void initState() {
    super.initState();
    final values = widget.routineLogDtos.map((log) => _heaviestWeightPerLog(log: log)).toList().reversed.toList();
    _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();

    _dateTimes =
        widget.routineLogDtos.map((log) => _dateTimePerLog(log: log).formattedDayAndMonth()).toList().reversed.toList();
  }
}

class HistoryWidget extends StatelessWidget {
  final List<RoutineLogDto> logs;

  const HistoryWidget({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
                itemBuilder: (BuildContext context, int index) => RoutineLogLiteWidget(
                      routineLogDto: logs[index],
                    ),
                separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 18),
                itemCount: logs.length),
          ),
        ],
      ),
    );
  }
}

class MetricWidget extends StatelessWidget {
  const MetricWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.summary, required this.onTap,
  });

  final String title;
  final String subtitle;
  final String summary;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        splashColor: tealBlueLight
      ),
      child: ListTile(
        onTap: onTap,
        tileColor: tealBlueLight,
        title: Text(title, style: const TextStyle(fontSize: 14, color: Colors.white)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7))),
        trailing: Text(summary, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      ),
    );
  }
}

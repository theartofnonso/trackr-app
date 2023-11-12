import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/enums.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/providers/exercise_provider.dart';
import 'package:tracker_app/providers/routine_log_provider.dart';
import 'package:tracker_app/screens/editor/exercise_editor_screen.dart';
import 'package:tracker_app/screens/settings_screen.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';

import '../../dtos/procedure_dto.dart';
import '../../dtos/set_dto.dart';
import '../../dtos/weighted_set_dto.dart';
import '../../models/Exercise.dart';
import '../../models/RoutineLog.dart';
import '../../shared_prefs.dart';
import '../../utils/general_utils.dart';
import '../../utils/snackbar_utils.dart';
import '../../widgets/chart/line_chart_widget.dart';
import '../../widgets/empty_states/screen_empty_state.dart';
import '../../widgets/exercise_history/routine_log_widget.dart';
import '../../dtos/graph/chart_point_dto.dart';
import '../../widgets/helper_widgets/dialog_helper.dart';
import '../routine/logs/routine_log_preview_screen.dart';

const exerciseRouteName = "/exercise-history-screen";

ChartUnit weightUnit() {
  return SharedPrefs().weightUnit == WeightUnit.kg.name ? ChartUnit.kg : ChartUnit.lbs;
}

List<SetDto> _allSetsWithWeight({required List<String> procedureJsons}) {
  final procedures = procedureJsons.map((json) => ProcedureDto.fromJson(jsonDecode(json))).toList();
  return procedures.where((procedure) =>
  ExerciseType.fromString(procedure.exercise.type) == ExerciseType.weightAndReps ||
      ExerciseType.fromString(procedure.exercise.type) == ExerciseType.weightedBodyWeight ||
      ExerciseType.fromString(procedure.exercise.type) == ExerciseType.bodyWeightAndReps)
      .expand((procedure) => procedure.sets)
      .toList();
}

List<SetDto> _allSetsWithReps({required List<String> procedureJsons}) {
  final procedures = procedureJsons.map((json) => ProcedureDto.fromJson(jsonDecode(json))).toList();
  return procedures.where((procedure) =>
  ExerciseType.fromString(procedure.exercise.type) == ExerciseType.weightAndReps ||
      ExerciseType.fromString(procedure.exercise.type) == ExerciseType.weightedBodyWeight ||
      ExerciseType.fromString(procedure.exercise.type) == ExerciseType.assistedBodyWeight ||
      ExerciseType.fromString(procedure.exercise.type) == ExerciseType.bodyWeightAndReps)
      .expand((procedure) => procedure.sets)
      .toList();
}

List<SetDto> _allSetsWithDuration({required List<String> procedureJsons}) {
  final procedures = procedureJsons.map((json) => ProcedureDto.fromJson(jsonDecode(json))).toList();
  return procedures.where((procedure) =>
  ExerciseType.fromString(procedure.exercise.type) == ExerciseType.duration ||
      ExerciseType.fromString(procedure.exercise.type) == ExerciseType.distanceAndDuration)
      .expand((procedure) => procedure.sets)
      .toList();
}

List<SetDto> _allSetsWithDistance({required List<String> procedureJsons}) {
  final procedures = procedureJsons.map((json) => ProcedureDto.fromJson(jsonDecode(json))).toList();
  return procedures.where((procedure) =>
  ExerciseType.fromString(procedure.exercise.type) == ExerciseType.weightAndDistance ||
      ExerciseType.fromString(procedure.exercise.type) == ExerciseType.distanceAndDuration)
      .expand((procedure) => procedure.sets)
      .toList();
}

/// Highest value per [RoutineLogDto]

WeightedSetDto _heaviestWeightInSetPerLog({required RoutineLog log}) {
  double heaviestWeight = 0;
  WeightedSetDto setWithHeaviestWeight = WeightedSetDto();

  final sets = _allSetsWithWeight(procedureJsons: log.procedures);

  for (var set in sets) {
    final weight = (set as WeightedSetDto).second;
    if (weight > heaviestWeight) {
      heaviestWeight = weight.toDouble();
      setWithHeaviestWeight = set;
    }
  }
  return setWithHeaviestWeight;
}

double _heaviestWeightPerLog({required RoutineLog log}) {
  double heaviestWeight = 0;

  final sets = _allSetsWithWeight(procedureJsons: log.procedures);

  for (var set in sets) {
    final weight = (set as WeightedSetDto).second;
    if (weight > heaviestWeight) {
      heaviestWeight = weight.toDouble();
    }
  }

  final weight = isDefaultWeightUnit() ? heaviestWeight : toLbs(heaviestWeight);

  return weight;
}

int repsPerLog({required RoutineLog log}) {
  int totalReps = 0;

  final sets = _allSetsWithReps(procedureJsons: log.procedures);

  for (var set in sets) {
    final reps = (set as WeightedSetDto).first;
    totalReps += reps.toInt();
  }
  return totalReps;
}

double _heaviestSetVolumePerLog({required RoutineLog log}) {
  double heaviestVolume = 0;

  final sets = _allSetsWithWeight(procedureJsons: log.procedures);

  for (var set in sets) {
    final volume = (set as WeightedSetDto).first * set.second;
    if (volume > heaviestVolume) {
      heaviestVolume = volume.toDouble();
    }
  }

  final volume = isDefaultWeightUnit() ? heaviestVolume : toLbs(heaviestVolume);

  return volume;
}

double volumePerLog({required RoutineLog log}) {
  double totalVolume = 0;

  final sets = _allSetsWithWeight(procedureJsons: log.procedures);

  for (var set in sets) {
    final volume = (set as WeightedSetDto).first * set.second;
    totalVolume += volume;
  }

  final volume = isDefaultWeightUnit() ? totalVolume : toLbs(totalVolume);

  return volume;
}

double _oneRepMaxPerLog({required RoutineLog log}) {
  final heaviestWeightInSet = _heaviestWeightInSetPerLog(log: log);

  final max = (heaviestWeightInSet.second * (1 + 0.0333 * heaviestWeightInSet.first));

  final maxWeight = isDefaultWeightUnit() ? max : toLbs(max);

  return maxWeight;
}

DateTime dateTimePerLog({required RoutineLog log}) {
  return log.createdAt.getDateTimeInUtc();
}

Duration durationPerLog({required RoutineLog log}) {
  final startTime = log.startTime.getDateTimeInUtc();
  final endTime = log.endTime.getDateTimeInUtc();
  final difference = endTime.difference(startTime);
  return difference;
}

double _totalVolumePerLog({required RoutineLog log}) {
  double totalVolume = 0;

  final sets = _allSetsWithWeight(procedureJsons: log.procedures);

  for (var set in sets) {
    final volume = (set as WeightedSetDto).first * set.second;
    totalVolume += volume;
  }

  final volume = isDefaultWeightUnit() ? totalVolume : toLbs(totalVolume);

  return volume;
}

/// Highest value across all [RoutineLogDto]

(String, WeightedSetDto) _heaviestSet({required List<RoutineLog> logs}) {
  WeightedSetDto heaviestSet = WeightedSetDto();
  String logId = "";
  for (var log in logs) {
    final sets = _allSetsWithWeight(procedureJsons: log.procedures);
    for (var set in sets) {
      final volume = (set as WeightedSetDto).first * set.second;
      if (volume > (heaviestSet.first * heaviestSet.second)) {
        heaviestSet = set;
        logId = log.id;
      }
    }
  }

  final weight = isDefaultWeightUnit() ? heaviestSet.second : toLbs(heaviestSet.second.toDouble());

  return (logId, heaviestSet.copyWith(second: weight));
}

(String, double) _heaviestLogVolume({required List<RoutineLog> logs}) {
  double heaviestVolume = 0;
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

(String, double) _heaviestWeight({required List<RoutineLog> logs}) {
  double heaviestWeight = 0;
  String logId = "";
  for (var log in logs) {
    final weight = _heaviestWeightPerLog(log: log);
    if (weight > heaviestWeight) {
      heaviestWeight = weight;
      logId = log.id;
    }
  }
  return (logId, heaviestWeight);
}

class ExerciseHistoryScreen extends StatelessWidget {
  final Exercise exercise;

  const ExerciseHistoryScreen({super.key, required this.exercise});

  List<RoutineLog> _logsWhereExercise({required List<RoutineLog> logs}) {
    return logs
        .where((log) =>
        log.procedures
            .map((json) => ProcedureDto.fromJson(jsonDecode(json)))
            .any((procedure) => procedure.exercise.id == exercise.id))
        .map((log) =>
        log.copyWith(
            procedures: log.procedures
                .where((procedure) =>
            ProcedureDto
                .fromJson(jsonDecode(procedure))
                .exercise
                .id == exercise.id)
                .toList()))
        .toList();
  }

  /// [MenuItemButton]
  List<Widget> _menuActionButtons({required BuildContext context, required Exercise exercise}) {
    return [
      MenuItemButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => ExerciseEditorScreen(exercise: exercise)));
        },
        leadingIcon: const Icon(Icons.edit),
        child: const Text("Edit"),
      ),
      MenuItemButton(
        onPressed: () {
          final alertDialogActions = <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel', style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.red)),
            ),
            CTextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await Provider.of<ExerciseProvider>(context, listen: false).removeExercise(id: exercise.id);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  } catch (_) {
                    if (context.mounted) {
                      showSnackbar(
                          context: context,
                          icon: const Icon(Icons.info_outline),
                          message: "Oops, we are unable delete this exercise");
                    }
                  }
                },
                label: 'Delete'),
          ];
          showAlertDialog(context: context, message: "Delete exercise?", actions: alertDialogActions);
        },
        leadingIcon: const Icon(Icons.delete_sweep, color: Colors.red),
        child: Text("Delete", style: GoogleFonts.lato(color: Colors.red)),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    final foundExercise =
        Provider.of<ExerciseProvider>(context, listen: true).whereExerciseOrNull(exerciseId: exercise.id) ?? exercise;

    final routineLogs = Provider
        .of<RoutineLogProvider>(context, listen: true)
        .logs;

    final routineLogsForExercise = _logsWhereExercise(logs: routineLogs);

    final heaviestRoutineLogVolume = _heaviestLogVolume(logs: routineLogsForExercise);

    final heaviestSet = _heaviestSet(logs: routineLogsForExercise);

    final heaviestWeight = _heaviestWeight(logs: routineLogsForExercise);

    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_outlined),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(foundExercise.name,
                style: GoogleFonts.lato(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
            bottom: const TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(
                  text: "Summary",
                ),
                Tab(
                  text: "History",
                ),
                Tab(
                  text: "Notes",
                )
              ],
            ),
            actions: [
              MenuAnchor(
                style: MenuStyle(
                  backgroundColor: MaterialStateProperty.all(tealBlueLighter),
                ),
                builder: (BuildContext context, MenuController controller, Widget? child) {
                  return IconButton(
                    onPressed: () {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    },
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    tooltip: 'Show menu',
                  );
                },
                menuChildren: _menuActionButtons(context: context, exercise: foundExercise),
              )
            ],
          ),
          body: TabBarView(
            children: [
              SummaryWidget(
                heaviestWeight: heaviestWeight,
                heaviestSet: heaviestSet,
                heaviestRoutineLogVolume: heaviestRoutineLogVolume,
                routineLogs: routineLogsForExercise,
                exercise: foundExercise,
              ),
              HistoryWidget(logs: routineLogsForExercise),
              NotesWidget(notes: foundExercise.notes)
            ],
          ),
        ));
  }
}

class SummaryWidget extends StatefulWidget {
  final (String, double) heaviestWeight;
  final (String, WeightedSetDto) heaviestSet;
  final (String, double) heaviestRoutineLogVolume;
  final List<RoutineLog> routineLogs;
  final Exercise exercise;

  const SummaryWidget({super.key,
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
  List<RoutineLog> _routineLogs = [];

  List<String> _dateTimes = [];

  List<ChartPointDto> _chartPoints = [];

  late ChartUnit _chartUnit;

  late SummaryType _summaryType = SummaryType.heaviestWeights;

  HistoricalTimePeriod _selectedHistoricalDate = HistoricalTimePeriod.allTime;

  void _heaviestWeights() {
    final values = _routineLogs.map((log) => _heaviestWeightPerLog(log: log)).toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = SummaryType.heaviestWeights;
      _chartUnit = weightUnit();
    });
  }

  void _heaviestSetVolumes() {
    final values = _routineLogs.map((log) => _heaviestSetVolumePerLog(log: log)).toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = SummaryType.heaviestSetVolumes;
      _chartUnit = weightUnit();
    });
  }

  void _logVolumes() {
    final values = _routineLogs.map((log) => volumePerLog(log: log)).toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = SummaryType.logVolumes;
      _chartUnit = weightUnit();
    });
  }

  void _oneRepMaxes() {
    final values = _routineLogs.map((log) => _oneRepMaxPerLog(log: log)).toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = SummaryType.oneRepMaxes;
      _chartUnit = ChartUnit.reps;
    });
  }

  void _reps() {
    final values = widget.routineLogs
        .map((log) => repsPerLog(log: log))
        .toList()
        .reversed
        .toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = SummaryType.reps;
      _chartUnit = ChartUnit.reps;
    });
  }

  void _recomputeChart() {
    switch (_selectedHistoricalDate) {
      case HistoricalTimePeriod.lastThreeMonths:
        _routineLogs = Provider
            .of<RoutineLogProvider>(context, listen: false)
            .routineLogsSince(90, logs: widget.routineLogs)
            .reversed
            .toList();
      case HistoricalTimePeriod.lastOneYear:
        _routineLogs = Provider
            .of<RoutineLogProvider>(context, listen: false)
            .routineLogsSince(365, logs: widget.routineLogs)
            .reversed
            .toList();
      case HistoricalTimePeriod.allTime:
        _routineLogs = widget.routineLogs.reversed.toList();
    }
    _dateTimes = _routineLogs.map((log) => dateTimePerLog(log: log).formattedDayAndMonth()).toList();
    switch (_summaryType) {
      case SummaryType.heaviestWeights:
        _heaviestWeights();
      case SummaryType.heaviestSetVolumes:
        _heaviestSetVolumes();
      case SummaryType.logVolumes:
        _logVolumes();
      case SummaryType.oneRepMaxes:
        _oneRepMaxes();
      case SummaryType.reps:
        _reps();
    }
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

      final oneRepMax = widget.routineLogs
          .map((log) => _oneRepMaxPerLog(log: log))
          .toList()
          .max;
      return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 12, right: 10.0, bottom: 10, left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Primary Muscle: ${widget.exercise.primaryMuscle}",
                  style: GoogleFonts.lato(
                      color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500, fontSize: 12),
                ),
                const SizedBox(height: 5),
                Text(
                  "Secondary Muscle: ${widget.exercise.secondaryMuscles.isNotEmpty ? widget.exercise.secondaryMuscles
                      .join(", ") : "None"}",
                  style: GoogleFonts.lato(
                      color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500, fontSize: 12),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, right: 20, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      DropdownButton<String>(
                        isDense: true,
                        value: _selectedHistoricalDate.label,
                        underline: Container(
                          color: Colors.transparent,
                        ),
                        style: GoogleFonts.lato(color: Colors.white),
                        onChanged: (String? value) {
                          // This is called when the user selects an item.
                          if (value != null) {
                            setState(() {
                              _selectedHistoricalDate = switch (value) {
                                "Last 3 months" => HistoricalTimePeriod.lastThreeMonths,
                                "Last 1 year" => HistoricalTimePeriod.lastOneYear,
                                "All Time" => HistoricalTimePeriod.allTime,
                                _ => HistoricalTimePeriod.allTime
                              };
                              _recomputeChart();
                            });
                          }
                        },
                        items: HistoricalTimePeriod.values
                            .map<DropdownMenuItem<String>>((HistoricalTimePeriod historicalDate) {
                          return DropdownMenuItem<String>(
                            value: historicalDate.label,
                            child: Text(historicalDate.label, style: GoogleFonts.lato(fontSize: 12)),
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
                  summary: "${widget.heaviestSet.$2.second}$weightUnitLabel x ${widget.heaviestSet.$2.first}",
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Primary Muscle: ${widget.exercise.primaryMuscle}",
          style: GoogleFonts.lato(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500, fontSize: 12),
        ),
        const SizedBox(height: 5),
        Text(
          "Secondary Muscle: ${widget.exercise.secondaryMuscles.isNotEmpty
              ? widget.exercise.secondaryMuscles.join(", ")
              : "None"}",
          style: GoogleFonts.lato(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500, fontSize: 12),
        )
      ],
    );
  }

  void _loadChart() {
    _routineLogs = widget.routineLogs.reversed.toList();

    _dateTimes =
        widget.routineLogs
            .map((log) => dateTimePerLog(log: log).formattedDayAndMonth())
            .toList()
            .reversed
            .toList();
    _heaviestWeights();
  }

  @override
  void initState() {
    super.initState();
    _loadChart();
  }
}

class HistoryWidget extends StatelessWidget {
  final List<RoutineLog> logs;

  const HistoryWidget({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          logs.isNotEmpty
              ? Expanded(
            child: ListView.separated(
                itemBuilder: (BuildContext context, int index) => RoutineLogWidget(routineLog: logs[index]),
                separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 8),
                itemCount: logs.length),
          )
              : const Center(child: ScreenEmptyState(message: "You have no logs")),
        ],
      ),
    );
  }
}

class NotesWidget extends StatelessWidget {
  final String? notes;

  const NotesWidget({super.key, required this.notes});

  @override
  Widget build(BuildContext context) {
    final exerciseNotes = notes;
    return exerciseNotes != null
        ? Padding(padding: const EdgeInsets.only(top: 12, right: 10, bottom: 10, left: 10), child: Text(exerciseNotes))
        : const Center(child: ScreenEmptyState(message: "You have no notes"));
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
        title: Text(title, style: GoogleFonts.lato(fontSize: 14, color: Colors.white)),
        subtitle: Text(subtitle, style: GoogleFonts.lato(fontSize: 14, color: Colors.white.withOpacity(0.7))),
        trailing:
        Text(summary, style: GoogleFonts.lato(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      ),
    );
  }
}

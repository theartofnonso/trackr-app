import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/widgets/exercise_history/personal_best_widget.dart';

import '../../../app_constants.dart';
import '../../../dtos/graph/chart_point_dto.dart';
import '../../../dtos/set_dto.dart';
import '../../../enums/exercise_type_enums.dart';
import '../../../providers/routine_log_provider.dart';
import '../../../utils/exercise_logs_utils.dart';
import '../../../utils/general_utils.dart';
import '../../../widgets/buttons/text_button_widget.dart';
import '../../../widgets/chart/line_chart_widget.dart';
import '../../routine_log_screen.dart';
import 'home_screen.dart';

enum SummaryType {
  weight,
  setVolume,
  bestTime,
  mostReps,
  sessionReps,
  sessionTimes,
}

class ExerciseChartScreen extends StatefulWidget {
  final (String?, double) heaviestWeight;
  final (String?, SetDto) heaviestSet;
  final (String?, Duration) longestDuration;
  final (String?, int) mostRepsSet;
  final (String?, int) mostRepsSession;
  final ExerciseDto exercise;

  const ExerciseChartScreen(
      {super.key,
      required this.heaviestWeight,
      required this.heaviestSet,
      required this.longestDuration,
      required this.mostRepsSet,
      required this.mostRepsSession,
      required this.exercise});

  @override
  State<ExerciseChartScreen> createState() => _ExerciseChartScreenState();
}

class _ExerciseChartScreenState extends State<ExerciseChartScreen> {
  List<ExerciseLogDto> _exerciseLogs = [];

  List<String> _dateTimes = [];

  List<ChartPointDto> _chartPoints = [];

  late ChartUnitLabel _chartUnit;

  late SummaryType _summaryType;

  void _heaviestWeightPerLog() {
    final sets = _exerciseLogs.map((log) => heaviestSetWeightForExerciseLog(exerciseLog: log)).toList();
    setState(() {
      _chartPoints = sets.mapIndexed((index, set) => ChartPointDto(index.toDouble(), set.value1.toDouble())).toList();
      _summaryType = SummaryType.weight;
      _chartUnit = weightUnit();
    });
  }

  void _heaviestSetVolumePerLog() {
    final values = _exerciseLogs.map((log) => heaviestVolumeForExerciseLog(exerciseLog: log)).toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = SummaryType.setVolume;
      _chartUnit = weightUnit();
    });
  }

  void _totalRepsForLog() {
    final values = _exerciseLogs.map((log) => totalRepsForExerciseLog(exerciseLog: log)).toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = SummaryType.sessionReps;
      _chartUnit = ChartUnitLabel.reps;
    });
  }

  void _highestRepsForLog() {
    final values = _exerciseLogs.map((log) => highestRepsForExerciseLog(exerciseLog: log)).toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = SummaryType.mostReps;
      _chartUnit = ChartUnitLabel.reps;
    });
  }

  void _longestDurationPerLog() {
    final values = _exerciseLogs.map((log) => longestDurationForExerciseLog(exerciseLog: log)).toList();
    setState(() {
      _chartPoints =
          values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.inMinutes.toDouble())).toList();
      _summaryType = SummaryType.bestTime;
      _chartUnit = ChartUnitLabel.mins;
    });
  }

  void _totalTimePerLog() {
    final values = _exerciseLogs.map((log) => totalDurationExerciseLog(exerciseLog: log)).toList();
    setState(() {
      _chartPoints =
          values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.inMinutes.toDouble())).toList();
      _summaryType = SummaryType.sessionTimes;
      _chartUnit = ChartUnitLabel.mins;
    });
  }

  void _computeChart() {
    final exerciseType = widget.exercise.type;

    switch (exerciseType) {
      case ExerciseType.weights:
        _summaryType = SummaryType.weight;
        break;
      case ExerciseType.bodyWeight:
        _summaryType = SummaryType.mostReps;
        break;
      case ExerciseType.duration:
        _summaryType = SummaryType.bestTime;
        break;
    }

    final thisYear = thisYearDateRange();
    _exerciseLogs = Provider.of<RoutineLogProvider>(context, listen: false)
        .exerciseLogsWhereDateRange(range: thisYear, exercise: widget.exercise)
        .toList();

    _dateTimes = _exerciseLogs.map((log) => log.createdAt.formattedDayAndMonth()).toList();

    switch (_summaryType) {
      case SummaryType.weight:
        _heaviestWeightPerLog();
        break;
      case SummaryType.setVolume:
        _heaviestSetVolumePerLog();
        break;
      case SummaryType.mostReps:
        _highestRepsForLog();
        break;
      case SummaryType.sessionReps:
        _totalRepsForLog();
        break;
      case SummaryType.bestTime:
        _longestDurationPerLog();
        break;
      case SummaryType.sessionTimes:
        _totalTimePerLog();
        break;
    }
  }

  Color? _buttonColor({required SummaryType type}) {
    return _summaryType == type ? Colors.blueAccent : tealBlueLight;
  }

  void _navigateTo({required String? routineLogId}) {
    if (routineLogId != null) {
      final routineLog = Provider.of<RoutineLogProvider>(context, listen: false).whereRoutineLog(id: routineLogId);
      if (routineLog != null) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => RoutineLogPreviewScreen(log: routineLog, previousRouteName: exerciseRouteName)));
      }
    }
  }

  bool _exerciseLogsWithWeightsOnly() {
    final exerciseType = widget.exercise.type;
    return exerciseType == ExerciseType.weights;
  }

  bool _exerciseLogsWithReps() {
    final exerciseType = widget.exercise.type;
    return exerciseType == ExerciseType.weights || exerciseType == ExerciseType.bodyWeight;
  }

  bool _exerciseLogsWithRepsOnly() {
    final exerciseType = widget.exercise.type;
    return exerciseType == ExerciseType.bodyWeight;
  }

  bool _exerciseLogsDuration() {
    final exerciseType = widget.exercise.type;
    return exerciseType == ExerciseType.duration;
  }

  @override
  Widget build(BuildContext context) {
    final weightUnitLabel = weightLabel();

    return SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.only(top: 20, right: 10.0, bottom: 10, left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Text(
              "Training ${widget.exercise.primaryMuscleGroup.name}",
              style: GoogleFonts.montserrat(
                  color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(right: 20, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 16),
                LineChartWidget(
                  chartPoints: _chartPoints,
                  dateTimes: _dateTimes,
                  unit: _chartUnit,
                ),
              ],
            ),
          ),
          if (_exerciseLogs.isNotEmpty)
            SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_exerciseLogsWithWeightsOnly())
                      Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: CTextButton(
                            onPressed: _heaviestWeightPerLog,
                            label: "Heaviest Weight",
                            buttonColor: _buttonColor(type: SummaryType.weight)),
                      ),
                    if (_exerciseLogsWithWeightsOnly())
                      Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: CTextButton(
                            onPressed: _heaviestSetVolumePerLog,
                            label: "Heaviest Volume (Set)",
                            buttonColor: _buttonColor(type: SummaryType.setVolume)),
                      ),
                    if (_exerciseLogsWithReps())
                      Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: CTextButton(
                            onPressed: _highestRepsForLog,
                            label: "Most Reps (Set)",
                            buttonColor: _buttonColor(type: SummaryType.mostReps)),
                      ),
                    if (_exerciseLogsWithRepsOnly())
                      Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: CTextButton(
                            onPressed: _totalRepsForLog,
                            label: "Session Reps",
                            buttonColor: _buttonColor(type: SummaryType.sessionReps)),
                      ),
                    if (_exerciseLogsDuration())
                      Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: CTextButton(
                            onPressed: _longestDurationPerLog,
                            label: "Best Time",
                            buttonColor: _buttonColor(type: SummaryType.bestTime)),
                      ),
                    if (_exerciseLogsDuration())
                      Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: CTextButton(
                            onPressed: _totalTimePerLog,
                            label: "Total Time",
                            buttonColor: _buttonColor(type: SummaryType.sessionTimes)),
                      ),
                  ],
                )),
          const SizedBox(height: 10),
          if (_exerciseLogsWithWeightsOnly())
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: _MetricListTile(
                title: 'Heaviest Weight',
                trailing: "${weightWithConversion(value: widget.heaviestWeight.$2)}$weightUnitLabel",
                subtitle: 'Heaviest weight in a set',
                onTap: () => _navigateTo(routineLogId: widget.heaviestWeight.$1),
                enabled: _exerciseLogs.isNotEmpty,
              ),
            ),
          if (_exerciseLogsWithWeightsOnly())
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: _MetricListTile(
                  title: 'Heaviest Set Volume',
                  trailing:
                      "${weightWithConversion(value: widget.heaviestSet.$2.value1)}$weightUnitLabel x ${widget.heaviestSet.$2.value2}",
                  subtitle: 'Heaviest volume in a set',
                  onTap: () => _navigateTo(routineLogId: widget.heaviestSet.$1),
                  enabled: _exerciseLogs.isNotEmpty),
            ),
          if (_exerciseLogsDuration())
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: _MetricListTile(
                  title: 'Best Time',
                  trailing: widget.longestDuration.$2.hmsAnalog(),
                  subtitle: 'Longest time for this exercise',
                  onTap: () => _navigateTo(routineLogId: widget.longestDuration.$1),
                  enabled: _exerciseLogs.isNotEmpty),
            ),
          if (_exerciseLogsWithReps())
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: _MetricListTile(
                  title: 'Most Reps (Set)',
                  trailing: "${widget.mostRepsSet.$2} reps",
                  subtitle: 'Most reps in a set',
                  onTap: () => _navigateTo(routineLogId: widget.mostRepsSet.$1),
                  enabled: _exerciseLogs.isNotEmpty),
            ),
          if (_exerciseLogsWithRepsOnly())
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: _MetricListTile(
                  title: 'Most Reps (Session)',
                  trailing: "${widget.mostRepsSession.$2} reps",
                  subtitle: 'Most reps in a session',
                  onTap: () => _navigateTo(routineLogId: widget.mostRepsSession.$1),
                  enabled: _exerciseLogs.isNotEmpty),
            ),
          if (_exerciseLogsWithWeightsOnly()) PersonalBestWidget(exercise: widget.exercise),
        ],
      ),
    ));
  }

  @override
  void initState() {
    super.initState();
    _computeChart();
  }
}

class _MetricListTile extends StatelessWidget {
  const _MetricListTile(
      {required this.title,
      required this.subtitle,
      required this.trailing,
      required this.onTap,
      required this.enabled});

  final String title;
  final String subtitle;
  final String trailing;
  final Function()? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(splashColor: tealBlueLight),
      child: ListTile(
        onTap: enabled ? onTap : () {},
        tileColor: tealBlueLight,
        title:
            Text(title, style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white.withOpacity(0.7))),
        trailing: Text(trailing,
            style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
    );
  }
}

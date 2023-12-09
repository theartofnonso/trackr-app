import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/extensions/duration_extension.dart';

import '../../../app_constants.dart';
import '../../../dtos/graph/chart_point_dto.dart';
import '../../../dtos/set_dto.dart';
import '../../../enums.dart';
import '../../../enums/exercise_type_enums.dart';
import '../../../models/Exercise.dart';
import '../../../providers/routine_log_provider.dart';
import '../../../utils/general_utils.dart';
import '../../../widgets/buttons/text_button_widget.dart';
import '../../../widgets/chart/line_chart_widget.dart';
import '../../../routine_log_preview_screen.dart';
import 'home_screen.dart';

enum SummaryType {
  heaviestWeight,
  heaviestSetVolume,
  oneRepMax,
  bestTime,
  mostReps,
  longestDistance,
  sessionReps,
  sessionTimes,
  sessionDistance,
}

class ExerciseChartScreen extends StatefulWidget {
  final (String, double) heaviestWeight;
  final (String, SetDto) heaviestSet;
  final (String, Duration) longestDuration;
  final (String, double) longestDistance;
  final (String, int) mostRepsSet;
  final (String, int) mostRepsSession;
  final Exercise exercise;

  const ExerciseChartScreen(
      {super.key,
      required this.heaviestWeight,
      required this.heaviestSet,
      required this.longestDuration,
      required this.longestDistance,
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

  late SummaryType _summaryType = SummaryType.heaviestWeight;

  ChartTimePeriod _selectedChartTimePeriod = ChartTimePeriod.thisMonth;

  void _heaviestWeightPerLog() {
    final values =
        _exerciseLogs.map((log) => heaviestWeightPerLog(exerciseLog: log)).toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = SummaryType.heaviestWeight;
      _chartUnit = weightUnit();
    });
  }

  void _heaviestSetVolumePerLog() {
    final values =
        _exerciseLogs.map((log) => heaviestSetVolumePerLog(exerciseLog: log)).toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = SummaryType.heaviestSetVolume;
      _chartUnit = weightUnit();
    });
  }

  void _oneRepMaxPerLog() {
    final values = _exerciseLogs.map((log) => oneRepMaxPerLog(exerciseLog: log)).toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = SummaryType.oneRepMax;
      _chartUnit = weightUnit();
    });
  }

  void _totalRepsForLog() {
    final values = _exerciseLogs
        .map((log) => totalRepsForLog(exerciseLog: log))
        .toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = SummaryType.sessionReps;
      _chartUnit = ChartUnitLabel.reps;
    });
  }

  void _highestRepsForLog() {
    final values = _exerciseLogs.map((log) => highestRepsForLog(exerciseLog: log)).toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = SummaryType.mostReps;
      _chartUnit = ChartUnitLabel.reps;
    });
  }

  void _longestDurationPerLog() {
    final values = _exerciseLogs
        .map((log) => longestDurationPerLog(exerciseLog: log))
        .toList();
    setState(() {
      _chartPoints =
          values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.inMinutes.toDouble())).toList();
      _summaryType = SummaryType.bestTime;
      _chartUnit = ChartUnitLabel.mins;
    });
  }

  void _totalTimePerLog() {
    final values = _exerciseLogs
        .map((log) => totalDurationPerLog(exerciseLog: log))
        .toList();
    setState(() {
      _chartPoints =
          values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.inMinutes.toDouble())).toList();
      _summaryType = SummaryType.sessionTimes;
      _chartUnit = ChartUnitLabel.mins;
    });
  }

  void _longestDistancePerLog() {
    final values = _exerciseLogs
        .map((log) => longestDistancePerLog(exerciseLog: log))
        .toList();
    final exerciseTypeString = widget.exercise.type;
    final exerciseType = ExerciseType.fromString(exerciseTypeString);
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = SummaryType.longestDistance;
      _chartUnit = exerciseType == ExerciseType.weightAndDistance ? ChartUnitLabel.yd : ChartUnitLabel.mi;
    });
  }

  void _totalDistancePerLog() {
    final values = _exerciseLogs
        .map((log) => totalDistancePerLog(exerciseLog: log))
        .toList();
    final exerciseTypeString = widget.exercise.type;
    final exerciseType = ExerciseType.fromString(exerciseTypeString);
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = SummaryType.sessionDistance;
      _chartUnit = exerciseType == ExerciseType.weightAndDistance ? ChartUnitLabel.yd : ChartUnitLabel.mi;
    });
  }

  void _computeChart() {
    switch (_selectedChartTimePeriod) {
      case ChartTimePeriod.thisWeek:
        final thisWeek = thisWeekDateRange();
        _exerciseLogs = Provider.of<RoutineLogProvider>(context, listen: false)
            .logsWhereDateRange(range: thisWeek, exercise: widget.exercise)
            .toList();
        break;
      case ChartTimePeriod.thisMonth:
        final thisMonth = thisMonthDateRange();
        _exerciseLogs = Provider.of<RoutineLogProvider>(context, listen: false)
            .logsWhereDateRange(range: thisMonth, exercise: widget.exercise)
            .toList();
        break;
      case ChartTimePeriod.thisYear:
        final thisYear = thisYearDateRange();
        _exerciseLogs = Provider.of<RoutineLogProvider>(context, listen: false)
            .logsWhereDateRange(range: thisYear, exercise: widget.exercise)
            .toList();
        break;
    }
    _dateTimes = _exerciseLogs.map((log) => dateTimePerLog(log: log).formattedDayAndMonth()).toList();
    switch (_summaryType) {
      case SummaryType.heaviestWeight:
        _heaviestWeightPerLog();
        break;
      case SummaryType.heaviestSetVolume:
        _heaviestSetVolumePerLog();
        break;
      case SummaryType.oneRepMax:
        _oneRepMaxPerLog();
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
      case SummaryType.longestDistance:
        _longestDistancePerLog();
        break;
      case SummaryType.sessionDistance:
        _totalDistancePerLog();
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

  bool _proceduresWithWeights() {
    final exerciseTypeString = widget.exercise.type;
    final exerciseType = ExerciseType.fromString(exerciseTypeString);
    return exerciseType == ExerciseType.weightAndReps ||
        exerciseType == ExerciseType.weightedBodyWeight ||
        exerciseType == ExerciseType.weightAndDistance;
  }

  bool _proceduresWithWeightsAndReps() {
    final exerciseTypeString = widget.exercise.type;
    final exerciseType = ExerciseType.fromString(exerciseTypeString);
    return exerciseType == ExerciseType.weightAndReps || exerciseType == ExerciseType.weightedBodyWeight;
  }

  bool _proceduresWithRepsOnly() {
    final exerciseTypeString = widget.exercise.type;
    final exerciseType = ExerciseType.fromString(exerciseTypeString);
    return exerciseType == ExerciseType.assistedBodyWeight ||
        exerciseType == ExerciseType.weightedBodyWeight ||
        exerciseType == ExerciseType.bodyWeightAndReps;
  }

  bool _proceduresDuration() {
    final exerciseTypeString = widget.exercise.type;
    final exerciseType = ExerciseType.fromString(exerciseTypeString);
    return exerciseType == ExerciseType.duration || exerciseType == ExerciseType.durationAndDistance;
  }

  bool _proceduresWithDistance() {
    final exerciseTypeString = widget.exercise.type;
    final exerciseType = ExerciseType.fromString(exerciseTypeString);
    return exerciseType == ExerciseType.durationAndDistance || exerciseType == ExerciseType.weightAndDistance;
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.lato(fontSize: 14);

    final weightUnitLabel = weightLabel();

    final exerciseTypeString = widget.exercise.type;
    final exerciseType = ExerciseType.fromString(exerciseTypeString);

    final distanceUnitLabel = distanceLabel(type: exerciseType);

    double oneRepMax = 0;
    if (_exerciseLogs.isNotEmpty) {
      oneRepMax = _exerciseLogs.map((log) => oneRepMaxPerLog(exerciseLog: log)).toList().max;
    }

    return SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.only(top: 20, right: 10.0, bottom: 10, left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Primary Muscle: ${widget.exercise.primaryMuscle}",
            style: GoogleFonts.lato(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500, fontSize: 12),
          ),
          const SizedBox(height: 5),
          Text(
            "Secondary Muscle: ${widget.exercise.secondaryMuscles.isNotEmpty ? widget.exercise.secondaryMuscles.join(", ") : "None"}",
            style: GoogleFonts.lato(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500, fontSize: 12),
          ),
          const SizedBox(height: 20),
          Center(
            child: CupertinoSlidingSegmentedControl<ChartTimePeriod>(
              backgroundColor: tealBlueLight,
              thumbColor: Colors.blue,
              groupValue: _selectedChartTimePeriod,
              children: {
                ChartTimePeriod.thisWeek:
                    SizedBox(width: 80, child: Text('This Week', style: textStyle, textAlign: TextAlign.center)),
                ChartTimePeriod.thisMonth:
                    SizedBox(width: 80, child: Text('This Month', style: textStyle, textAlign: TextAlign.center)),
                ChartTimePeriod.thisYear:
                    SizedBox(width: 80, child: Text('This Year', style: textStyle, textAlign: TextAlign.center)),
              },
              onValueChanged: (ChartTimePeriod? value) {
                if (value != null) {
                  setState(() {
                    _selectedChartTimePeriod = value;
                    _computeChart();
                  });
                }
              },
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
                    if (_proceduresWithWeights())
                      Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: CTextButton(
                            onPressed: _heaviestWeightPerLog,
                            label: "Heaviest Weight",
                            buttonColor: _buttonColor(type: SummaryType.heaviestWeight)),
                      ),
                    if (_proceduresWithWeightsAndReps())
                      Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: CTextButton(
                            onPressed: _heaviestSetVolumePerLog,
                            label: "Heaviest Set Volume",
                            buttonColor: _buttonColor(type: SummaryType.heaviestSetVolume)),
                      ),
                    if (_proceduresWithWeightsAndReps())
                      Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: CTextButton(
                            onPressed: _oneRepMaxPerLog,
                            label: "1RM",
                            buttonColor: _buttonColor(type: SummaryType.oneRepMax)),
                      ),
                    if (_proceduresWithRepsOnly())
                      Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: CTextButton(
                            onPressed: _highestRepsForLog,
                            label: "Most Reps (Set)",
                            buttonColor: _buttonColor(type: SummaryType.mostReps)),
                      ),
                    if (_proceduresWithRepsOnly())
                      Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: CTextButton(
                            onPressed: _totalRepsForLog,
                            label: "Session Reps",
                            buttonColor: _buttonColor(type: SummaryType.sessionReps)),
                      ),
                    if (_proceduresDuration())
                      Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: CTextButton(
                            onPressed: _longestDurationPerLog,
                            label: "Best Time",
                            buttonColor: _buttonColor(type: SummaryType.bestTime)),
                      ),
                    if (_proceduresDuration())
                      Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: CTextButton(
                            onPressed: _totalTimePerLog,
                            label: "Total Time",
                            buttonColor: _buttonColor(type: SummaryType.sessionTimes)),
                      ),
                    if (_proceduresWithDistance())
                      Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: CTextButton(
                            onPressed: _longestDistancePerLog,
                            label: "Longest Distance",
                            buttonColor: _buttonColor(type: SummaryType.longestDistance)),
                      ),
                    if (_proceduresWithDistance())
                      Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: CTextButton(
                            onPressed: _totalDistancePerLog,
                            label: "Total Distance",
                            buttonColor: _buttonColor(type: SummaryType.sessionDistance)),
                      ),
                  ],
                )),
          const SizedBox(height: 10),
          if (_proceduresWithWeights())
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: _MetricListTile(
                title: 'Heaviest weight',
                trailing: "${widget.heaviestWeight.$2}$weightUnitLabel",
                subtitle: 'Heaviest weight lifted in a set',
                onTap: () => _navigateTo(routineLogId: widget.heaviestWeight.$1),
                enabled: _exerciseLogs.isNotEmpty,
              ),
            ),
          if (_proceduresWithWeightsAndReps())
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: _MetricListTile(
                  title: 'Heaviest Set Volume',
                  trailing: "${widget.heaviestSet.$2.value1}$weightUnitLabel x ${widget.heaviestSet.$2.value2}",
                  subtitle: 'Heaviest volume lifted in a set',
                  onTap: () => _navigateTo(routineLogId: widget.heaviestSet.$1),
                  enabled: _exerciseLogs.isNotEmpty),
            ),
          if (_proceduresWithWeightsAndReps())
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: _MetricListTile(
                  title: '1 Rep Max',
                  trailing: '${oneRepMax.toStringAsFixed(2)}$weightUnitLabel',
                  subtitle: 'Heaviest weight for one rep',
                  onTap: () => _navigateTo(routineLogId: widget.heaviestWeight.$1),
                  enabled: _exerciseLogs.isNotEmpty),
            ),
          if (_proceduresDuration())
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: _MetricListTile(
                  title: 'Best Time',
                  trailing: widget.longestDuration.$2.secondsOrMinutesOrHours(),
                  subtitle: 'Longest time for this exercise',
                  onTap: () => _navigateTo(routineLogId: widget.longestDuration.$1),
                  enabled: _exerciseLogs.isNotEmpty),
            ),
          if (_proceduresWithDistance())
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: _MetricListTile(
                  title: 'Longest Distance',
                  trailing: "${widget.longestDistance.$2}$distanceUnitLabel",
                  subtitle: 'Longest distance for this exercise',
                  onTap: () => _navigateTo(routineLogId: widget.longestDistance.$1),
                  enabled: _exerciseLogs.isNotEmpty),
            ),
          if (_proceduresWithRepsOnly())
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: _MetricListTile(
                  title: 'Most Reps (Set)',
                  trailing: "${widget.mostRepsSet.$2} reps",
                  subtitle: 'Most reps in a set',
                  onTap: () => _navigateTo(routineLogId: widget.mostRepsSet.$1),
                  enabled: _exerciseLogs.isNotEmpty),
            ),
          if (_proceduresWithRepsOnly())
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: _MetricListTile(
                  title: 'Most Reps (Session)',
                  trailing: "${widget.mostRepsSession.$2} reps",
                  subtitle: 'Most reps in a session',
                  onTap: () => _navigateTo(routineLogId: widget.mostRepsSession.$1),
                  enabled: _exerciseLogs.isNotEmpty),
            ),
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
        title: Text(title, style: GoogleFonts.lato(fontSize: 14, color: Colors.white)),
        subtitle: Text(subtitle, style: GoogleFonts.lato(fontSize: 14, color: Colors.white.withOpacity(0.7))),
        trailing:
            Text(trailing, style: GoogleFonts.lato(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      ),
    );
  }
}

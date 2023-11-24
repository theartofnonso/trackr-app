import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/extensions/duration_extension.dart';

import '../../../app_constants.dart';
import '../../../dtos/graph/chart_point_dto.dart';
import '../../../dtos/set_dto.dart';
import '../../../enums.dart';
import '../../../enums/exercise_type_enums.dart';
import '../../../models/Exercise.dart';
import '../../../models/RoutineLog.dart';
import '../../../providers/routine_log_provider.dart';
import '../../../utils/general_utils.dart';
import '../../../widgets/buttons/text_button_widget.dart';
import '../../../widgets/chart/line_chart_widget.dart';
import '../../logs/routine_log_preview_screen.dart';
import 'home_screen.dart';

enum SummaryType {
  heaviestWeight,
  heaviestSetVolume,
  oneRepMax,
  bestTime,
  mostReps,
  longestDistance,
  sessionVolume,
  sessionReps,
  sessionTimes,
  sessionDistance,
}

class SummaryScreen extends StatefulWidget {
  final (String, double) heaviestWeight;
  final (String, SetDto) heaviestSet;
  final (String, double) heaviestRoutineLogVolume;
  final (String, Duration) longestDuration;
  final (String, double) longestDistance;
  final (String, int) mostRepsSet;
  final (String, int) mostRepsSession;
  final List<RoutineLog> routineLogs;
  final Exercise exercise;

  const SummaryScreen(
      {super.key,
      required this.heaviestWeight,
      required this.heaviestSet,
      required this.heaviestRoutineLogVolume,
      required this.longestDuration,
      required this.longestDistance,
      required this.mostRepsSet,
      required this.mostRepsSession,
      required this.routineLogs,
      required this.exercise});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  List<RoutineLog> _routineLogs = [];

  List<String> _dateTimes = [];

  List<ChartPointDto> _chartPoints = [];

  late ChartUnitLabel _chartUnit;

  late SummaryType _summaryType = SummaryType.heaviestWeight;

  HistoricalTimePeriod _selectedHistoricalDate = HistoricalTimePeriod.allTime;

  void _heaviestWeightPerLog() {
    final values = _routineLogs.map((log) => heaviestWeightPerLog(log: log)).toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = SummaryType.heaviestWeight;
      _chartUnit = weightUnit();
    });
  }

  void _heaviestSetVolumePerLog() {
    final values = _routineLogs.map((log) => heaviestSetVolumePerLog(log: log)).toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = SummaryType.heaviestSetVolume;
      _chartUnit = weightUnit();
    });
  }

  void _setVolumePerLog() {
    final values = _routineLogs.map((log) => setVolumePerLog(log: log)).toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = SummaryType.sessionVolume;
      _chartUnit = weightUnit();
    });
  }

  void _oneRepMaxPerLog() {
    final values = _routineLogs.map((log) => oneRepMaxPerLog(log: log)).toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = SummaryType.oneRepMax;
      _chartUnit = weightUnit();
    });
  }

  void _totalRepsPerLog() {
    final values = widget.routineLogs.map((log) => totalRepsPerLog(log: log)).toList().reversed.toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = SummaryType.sessionReps;
      _chartUnit = ChartUnitLabel.reps;
    });
  }

  void _mostRepsPerLog() {
    final values = _routineLogs.map((log) => mostRepsPerLog(log: log)).toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = SummaryType.mostReps;
      _chartUnit = ChartUnitLabel.reps;
    });
  }

  void _longestDurationPerLog() {
    final values = widget.routineLogs.map((log) => longestDurationPerLog(log: log)).toList().reversed.toList();
    setState(() {
      _chartPoints =
          values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.inMinutes.toDouble())).toList();
      _summaryType = SummaryType.bestTime;
      _chartUnit = ChartUnitLabel.mins;
    });
  }

  void _totalTimePerLog() {
    final values = widget.routineLogs.map((log) => totalDurationPerLog(log: log)).toList().reversed.toList();
    setState(() {
      _chartPoints =
          values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.inMinutes.toDouble())).toList();
      _summaryType = SummaryType.sessionTimes;
      _chartUnit = ChartUnitLabel.mins;
    });
  }

  void _longestDistancePerLog() {
    final values = widget.routineLogs.map((log) => longestDistancePerLog(log: log)).toList().reversed.toList();
    final exerciseTypeString = widget.exercise.type;
    final exerciseType = ExerciseType.fromString(exerciseTypeString);
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = SummaryType.longestDistance;
      _chartUnit = exerciseType == ExerciseType.weightAndDistance ? ChartUnitLabel.yd : ChartUnitLabel.mi;
    });
  }

  void _totalDistancePerLog() {
    final values = widget.routineLogs.map((log) => totalDistancePerLog(log: log)).toList().reversed.toList();
    final exerciseTypeString = widget.exercise.type;
    final exerciseType = ExerciseType.fromString(exerciseTypeString);
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = SummaryType.sessionDistance;
      _chartUnit = exerciseType == ExerciseType.weightAndDistance ? ChartUnitLabel.yd : ChartUnitLabel.mi;
    });
  }

  void _recomputeChart() {
    switch (_selectedHistoricalDate) {
      case HistoricalTimePeriod.lastThreeMonths:
        _routineLogs = Provider.of<RoutineLogProvider>(context, listen: false)
            .routineLogsSince(90, logs: widget.routineLogs)
            .reversed
            .toList();
        break;
      case HistoricalTimePeriod.lastOneYear:
        _routineLogs = Provider.of<RoutineLogProvider>(context, listen: false)
            .routineLogsSince(365, logs: widget.routineLogs)
            .reversed
            .toList();
        break;
      case HistoricalTimePeriod.allTime:
        _routineLogs = widget.routineLogs.reversed.toList();
    }
    _dateTimes = _routineLogs.map((log) => dateTimePerLog(log: log).formattedDayAndMonth()).toList();
    switch (_summaryType) {
      case SummaryType.heaviestWeight:
        _heaviestWeightPerLog();
        break;
      case SummaryType.heaviestSetVolume:
        _heaviestSetVolumePerLog();
        break;
      case SummaryType.sessionVolume:
        _setVolumePerLog();
        break;
      case SummaryType.oneRepMax:
        _oneRepMaxPerLog();
        break;
      case SummaryType.sessionReps:
        _totalRepsPerLog();
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
      case SummaryType.mostReps:
      // TODO: Handle this case.
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

  bool _proceduresWithReps() {
    final exerciseTypeString = widget.exercise.type;
    final exerciseType = ExerciseType.fromString(exerciseTypeString);
    return exerciseType == ExerciseType.weightAndReps ||
        exerciseType == ExerciseType.assistedBodyWeight ||
        exerciseType == ExerciseType.weightedBodyWeight ||
        exerciseType == ExerciseType.bodyWeightAndReps;
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
    return exerciseType == ExerciseType.duration || exerciseType == ExerciseType.distanceAndDuration;
  }

  bool _proceduresWithDistance() {
    final exerciseTypeString = widget.exercise.type;
    final exerciseType = ExerciseType.fromString(exerciseTypeString);
    return exerciseType == ExerciseType.distanceAndDuration || exerciseType == ExerciseType.weightAndDistance;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.routineLogs.isNotEmpty) {
      final weightUnitLabel = weightLabel();

      final exerciseTypeString = widget.exercise.type;
      final exerciseType = ExerciseType.fromString(exerciseTypeString);

      final distanceUnitLabel = distanceLabel(type: exerciseType);

      final oneRepMax = widget.routineLogs.map((log) => oneRepMaxPerLog(log: log)).toList().max;
      return SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.only(top: 12, right: 10.0, bottom: 10, left: 10),
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
                    if (_proceduresWithWeightsAndReps())
                      Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: CTextButton(
                            onPressed: _setVolumePerLog,
                            label: "Session Volume",
                            buttonColor: _buttonColor(type: SummaryType.sessionVolume)),
                      ),
                    if (_proceduresWithRepsOnly())
                      Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: CTextButton(
                            onPressed: _mostRepsPerLog,
                            label: "Most Reps (Set)",
                            buttonColor: _buttonColor(type: SummaryType.mostReps)),
                      ),
                    if (_proceduresWithReps())
                      Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: CTextButton(
                            onPressed: _totalRepsPerLog,
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
                ),
              ),
            if (_proceduresWithWeightsAndReps())
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: _MetricListTile(
                  title: 'Heaviest Session Volume',
                  trailing: "${widget.heaviestRoutineLogVolume.$2}$weightUnitLabel",
                  subtitle: 'Heaviest volume lifted in a session',
                  onTap: () => _navigateTo(routineLogId: widget.heaviestRoutineLogVolume.$1),
                ),
              ),
            if (_proceduresWithWeightsAndReps())
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: _MetricListTile(
                  title: '1 Rep Max',
                  trailing: '${oneRepMax.toStringAsFixed(2)}$weightUnitLabel',
                  subtitle: 'Heaviest weight for one rep',
                  onTap: () => _navigateTo(routineLogId: widget.heaviestWeight.$1),
                ),
              ),
            if (_proceduresDuration())
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: _MetricListTile(
                  title: 'Best Time',
                  trailing: widget.longestDuration.$2.secondsOrMinutesOrHours(),
                  subtitle: 'Longest time for this exercise',
                  onTap: () => _navigateTo(routineLogId: widget.longestDuration.$1),
                ),
              ),
            if (_proceduresWithDistance())
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: _MetricListTile(
                  title: 'Longest Distance',
                  trailing: "${widget.longestDistance.$2}$distanceUnitLabel",
                  subtitle: 'Longest distance for this exercise',
                  onTap: () => _navigateTo(routineLogId: widget.longestDistance.$1),
                ),
              ),
            if (_proceduresWithRepsOnly())
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: _MetricListTile(
                  title: 'Most Reps (Set)',
                  trailing: "${widget.mostRepsSet.$2} reps",
                  subtitle: 'Most reps in a set',
                  onTap: () => _navigateTo(routineLogId: widget.mostRepsSet.$1),
                ),
              ),
            if (_proceduresWithRepsOnly())
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: _MetricListTile(
                  title: 'Most Reps (Session)',
                  trailing: "${widget.mostRepsSession.$2} reps",
                  subtitle: 'Most reps in a session',
                  onTap: () => _navigateTo(routineLogId: widget.mostRepsSession.$1),
                ),
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
          "Secondary Muscle: ${widget.exercise.secondaryMuscles.isNotEmpty ? widget.exercise.secondaryMuscles.join(", ") : "None"}",
          style: GoogleFonts.lato(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500, fontSize: 12),
        )
      ],
    );
  }

  void _loadChart() {
    _routineLogs = widget.routineLogs.reversed.toList();

    _dateTimes = _routineLogs.map((log) => dateTimePerLog(log: log).formattedDayAndMonth()).toList();

    final exerciseTypeString = widget.exercise.type;
    final exerciseType = ExerciseType.fromString(exerciseTypeString);

    switch (exerciseType) {
      case ExerciseType.weightAndReps:
      case ExerciseType.weightedBodyWeight:
      case ExerciseType.weightAndDistance:
        _heaviestWeightPerLog();
        break;
      case ExerciseType.bodyWeightAndReps:
      case ExerciseType.assistedBodyWeight:
        _totalRepsPerLog();
        break;
      case ExerciseType.duration:
      case ExerciseType.distanceAndDuration:
        _longestDurationPerLog();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadChart();
  }
}

class _MetricListTile extends StatelessWidget {
  const _MetricListTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String trailing;
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
            Text(trailing, style: GoogleFonts.lato(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      ),
    );
  }
}

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/widgets/exercise_history/personal_best_widget.dart';

import '../../../colors.dart';
import '../../../dtos/graph/chart_point_dto.dart';
import '../../../dtos/set_dto.dart';
import '../../../enums/chart_unit_enum.dart';
import '../../../enums/exercise_type_enums.dart';
import '../../../controllers/routine_log_controller.dart';
import '../../../utils/exercise_logs_utils.dart';
import '../../../utils/general_utils.dart';
import '../../../widgets/buttons/text_button_widget.dart';
import '../../../widgets/chart/line_chart_widget.dart';
import '../../logs/routine_log_screen.dart';
import 'home_screen.dart';

enum SummaryType {
  weight("Heaviest Weight"),
  setVolume("Heaviest Volume (Set)"),
  bestTime("Best Time"),
  mostReps("Most Reps (Set)"),
  sessionReps("Most Reps (Session)"),
  sessionTimes("Total Time");

  const SummaryType(this.label);

  final String label;
}

class ExerciseChartScreen extends StatefulWidget {
  final (String?, double) heaviestWeight;
  final (String?, SetDto) heaviestSet;
  final (String?, Duration) longestDuration;
  final (String?, int) mostRepsSet;
  final (String?, int) mostRepsSession;
  final ExerciseDto exercise;
  final List<ExerciseLogDto> exerciseLogs;

  const ExerciseChartScreen(
      {super.key,
      required this.heaviestWeight,
      required this.heaviestSet,
      required this.longestDuration,
      required this.mostRepsSet,
      required this.mostRepsSession,
      required this.exercise,
      required this.exerciseLogs});

  @override
  State<ExerciseChartScreen> createState() => _ExerciseChartScreenState();
}

class _ExerciseChartScreenState extends State<ExerciseChartScreen> {
  List<String> _dateTimes = [];

  List<ChartPointDto> _chartPoints = [];

  late ChartUnit _chartUnit;

  late SummaryType _summaryType;

  void _heaviestWeightPerLog() {
    final sets = widget.exerciseLogs.map((log) => heaviestSetWeightForExerciseLog(exerciseLog: log)).toList();
    setState(() {
      _chartPoints = sets.mapIndexed((index, set) => ChartPointDto(index, set.weightValue())).toList();
      _summaryType = SummaryType.weight;
      _chartUnit = ChartUnit.weight;
    });
  }

  void _heaviestSetVolumePerLog() {
    final values = widget.exerciseLogs.map((log) => heaviestVolumeForExerciseLog(exerciseLog: log)).toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index, value)).toList();
      _summaryType = SummaryType.setVolume;
      _chartUnit = ChartUnit.weight;
    });
  }

  void _totalRepsForLog() {
    final values = widget.exerciseLogs.map((log) => totalRepsForExerciseLog(exerciseLog: log)).toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index, value)).toList();
      _summaryType = SummaryType.sessionReps;
      _chartUnit = ChartUnit.weight;
    });
  }

  void _highestRepsForLog() {
    final values = widget.exerciseLogs.map((log) => highestRepsForExerciseLog(exerciseLog: log)).toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index, value)).toList();
      _summaryType = SummaryType.mostReps;
      _chartUnit = ChartUnit.weight;
    });
  }

  void _longestDurationPerLog() {
    final values = widget.exerciseLogs.map((log) => longestDurationForExerciseLog(exerciseLog: log)).toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index, value.inMilliseconds)).toList();
      _summaryType = SummaryType.bestTime;
      _chartUnit = ChartUnit.duration;
    });
  }

  void _totalTimePerLog() {
    final values = widget.exerciseLogs.map((log) => totalDurationExerciseLog(exerciseLog: log)).toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index, value.inMilliseconds)).toList();
      _summaryType = SummaryType.sessionTimes;
      _chartUnit = ChartUnit.duration;
    });
  }

  void _computeChart() {
    switch (widget.exercise.type) {
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

    _dateTimes = widget.exerciseLogs.map((log) => log.createdAt.formattedDayAndMonth()).toList();

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

  @override
  void initState() {
    super.initState();
    _computeChart();
  }

  Color? _buttonColor({required SummaryType type}) {
    return _summaryType == type ? vibrantGreen : sapphireDark.withOpacity(0.6);
  }

  Color? _textColor({required SummaryType type}) {
    return _summaryType == type ? Colors.black : Colors.white;
  }

  void _navigateTo({required String? routineLogId}) {
    if (routineLogId != null) {
      final routineLog = Provider.of<RoutineLogController>(context, listen: false).logWhereId(id: routineLogId);
      if (routineLog != null) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => RoutineLogPreviewScreen(log: routineLog, previousRouteName: exerciseRouteName)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final weightUnitLabel = weightLabel();

    return SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.only(top: 2, right: 10.0, bottom: 10, left: 10),
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
                  periods: _dateTimes,
                  unit: _chartUnit,
                ),
              ],
            ),
          ),
          if (widget.exerciseLogs.isNotEmpty)
            SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (withWeightsOnly(type: widget.exercise.type))
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: CTextButton(
                            onPressed: _heaviestWeightPerLog,
                            label: SummaryType.weight.label,
                            textStyle: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w600, fontSize: 14, color: _textColor(type: SummaryType.weight)),
                            padding: const EdgeInsets.only(right: 5.0),
                            buttonColor: _buttonColor(type: SummaryType.weight)),
                      ),
                    if (withWeightsOnly(type: widget.exercise.type))
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: CTextButton(
                            onPressed: _heaviestSetVolumePerLog,
                            label: SummaryType.setVolume.label,
                            textStyle: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: _textColor(type: SummaryType.setVolume)),
                            padding: const EdgeInsets.only(right: 5.0),
                            buttonColor: _buttonColor(type: SummaryType.setVolume)),
                      ),
                    if (withReps(type: widget.exercise.type))
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: CTextButton(
                            onPressed: _highestRepsForLog,
                            label: SummaryType.mostReps.label,
                            textStyle: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: _textColor(type: SummaryType.mostReps)),
                            padding: const EdgeInsets.only(right: 5.0),
                            buttonColor: _buttonColor(type: SummaryType.mostReps)),
                      ),
                    if (withReps(type: widget.exercise.type))
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: CTextButton(
                            onPressed: _totalRepsForLog,
                            label: SummaryType.sessionReps.label,
                            textStyle: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: _textColor(type: SummaryType.sessionReps)),
                            padding: const EdgeInsets.only(right: 5.0),
                            buttonColor: _buttonColor(type: SummaryType.sessionReps)),
                      ),
                    if (withDurationOnly(type: widget.exercise.type))
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: CTextButton(
                            onPressed: _longestDurationPerLog,
                            label: SummaryType.bestTime.label,
                            textStyle: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: _textColor(type: SummaryType.bestTime)),
                            padding: const EdgeInsets.only(right: 5.0),
                            buttonColor: _buttonColor(type: SummaryType.bestTime)),
                      ),
                    if (withDurationOnly(type: widget.exercise.type))
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: CTextButton(
                            onPressed: _totalTimePerLog,
                            label: SummaryType.sessionTimes.label,
                            textStyle: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: _textColor(type: SummaryType.sessionTimes)),
                            padding: const EdgeInsets.only(right: 5.0),
                            buttonColor: _buttonColor(type: SummaryType.sessionTimes)),
                      ),
                  ],
                )),
          const SizedBox(height: 10),
          if (withWeightsOnly(type: widget.exercise.type))
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: _MetricListTile(
                title: 'Heaviest Weight',
                trailing: "${weightWithConversion(value: widget.heaviestWeight.$2)}$weightUnitLabel",
                subtitle: 'Heaviest weight in a set',
                onTap: () => _navigateTo(routineLogId: widget.heaviestWeight.$1),
                enabled: widget.exerciseLogs.isNotEmpty,
              ),
            ),
          if (withWeightsOnly(type: widget.exercise.type))
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: _MetricListTile(
                  title: 'Heaviest Set Volume',
                  trailing:
                      "${weightWithConversion(value: widget.heaviestSet.$2.weightValue())}$weightUnitLabel x ${widget.heaviestSet.$2.repsValue()}",
                  subtitle: 'Heaviest volume in a set',
                  onTap: () => _navigateTo(routineLogId: widget.heaviestSet.$1),
                  enabled: widget.exerciseLogs.isNotEmpty),
            ),
          if (withDurationOnly(type: widget.exercise.type))
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: _MetricListTile(
                  title: 'Best Time',
                  trailing: widget.longestDuration.$2.hmsAnalog(),
                  subtitle: 'Longest time for this exercise',
                  onTap: () => _navigateTo(routineLogId: widget.longestDuration.$1),
                  enabled: widget.exerciseLogs.isNotEmpty),
            ),
          if (withReps(type: widget.exercise.type))
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: _MetricListTile(
                  title: 'Most Reps (Set)',
                  trailing: "${widget.mostRepsSet.$2} reps",
                  subtitle: 'Most reps in a set',
                  onTap: () => _navigateTo(routineLogId: widget.mostRepsSet.$1),
                  enabled: widget.exerciseLogs.isNotEmpty),
            ),
          if (withReps(type: widget.exercise.type))
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: _MetricListTile(
                  title: 'Most Reps (Session)',
                  trailing: "${widget.mostRepsSession.$2} reps",
                  subtitle: 'Most reps in a session',
                  onTap: () => _navigateTo(routineLogId: widget.mostRepsSession.$1),
                  enabled: widget.exerciseLogs.isNotEmpty),
            ),
          if (withWeightsOnly(type: widget.exercise.type)) PersonalBestWidget(exercise: widget.exercise),
        ],
      ),
    ));
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: sapphireDark80,
      ),
      child: ListTile(
        onTap: enabled ? onTap : () {},
        tileColor: Colors.pinkAccent,
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

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/utils/datetime_utils.dart';

import '../../../app_constants.dart';
import '../../../dtos/graph/chart_point_dto.dart';
import '../../../dtos/set_dto.dart';
import '../../../enums.dart';
import '../../../models/Exercise.dart';
import '../../../models/RoutineLog.dart';
import '../../../providers/routine_log_provider.dart';
import '../../../utils/general_utils.dart';
import '../../../widgets/buttons/text_button_widget.dart';
import '../../../widgets/chart/line_chart_widget.dart';
import '../../routine/logs/routine_log_preview_screen.dart';
import 'exercise_history_screen.dart';

enum SummaryType { heaviestWeights, heaviestSetVolumes, logVolumes, oneRepMaxes, reps }

class SummaryScreen extends StatefulWidget {
  final (String, double) heaviestWeight;
  final (String, SetDto) heaviestSet;
  final (String, double) heaviestRoutineLogVolume;
  final List<RoutineLog> routineLogs;
  final Exercise exercise;

  const SummaryScreen(
      {super.key,
      required this.heaviestWeight,
      required this.heaviestSet,
      required this.routineLogs,
      required this.heaviestRoutineLogVolume,
      required this.exercise});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  List<RoutineLog> _routineLogs = [];

  List<String> _dateTimes = [];

  List<ChartPointDto> _chartPoints = [];

  late ChartUnit _chartUnit;

  late SummaryType _summaryType = SummaryType.heaviestWeights;

  HistoricalTimePeriod _selectedHistoricalDate = HistoricalTimePeriod.allTime;

  void _heaviestWeights() {
    final values = _routineLogs.map((log) => heaviestWeightPerLog(log: log)).toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = SummaryType.heaviestWeights;
      _chartUnit = weightUnit();
    });
  }

  void _heaviestSetVolumes() {
    final values = _routineLogs.map((log) => heaviestSetVolumePerLog(log: log)).toList();
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
    final values = _routineLogs.map((log) => oneRepMaxPerLog(log: log)).toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = SummaryType.oneRepMaxes;
      _chartUnit = ChartUnit.reps;
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

  void _recomputeChart() {
    switch (_selectedHistoricalDate) {
      case HistoricalTimePeriod.lastThreeMonths:
        _routineLogs = Provider.of<RoutineLogProvider>(context, listen: false)
            .routineLogsSince(90, logs: widget.routineLogs)
            .reversed
            .toList();
      case HistoricalTimePeriod.lastOneYear:
        _routineLogs = Provider.of<RoutineLogProvider>(context, listen: false)
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
            _MetricWidget(
              title: 'Heaviest weight',
              summary: "${widget.heaviestWeight.$2}$weightUnitLabel",
              subtitle: 'Heaviest weight lifted for a set',
              onTap: () => _navigateTo(routineLogId: widget.heaviestWeight.$1),
            ),
            const SizedBox(height: 10),
            _MetricWidget(
              title: 'Heaviest Set Volume',
              summary: "${widget.heaviestSet.$2.value1}$weightUnitLabel x ${widget.heaviestSet.$2.value2}",
              subtitle: 'Heaviest volume lifted for a set',
              onTap: () => _navigateTo(routineLogId: widget.heaviestSet.$1),
            ),
            const SizedBox(height: 10),
            _MetricWidget(
              title: 'Heaviest Session Volume',
              summary: "${widget.heaviestRoutineLogVolume.$2}$weightUnitLabel",
              subtitle: 'Heaviest volume lifted for a session',
              onTap: () => _navigateTo(routineLogId: widget.heaviestRoutineLogVolume.$1),
            ),
            const SizedBox(height: 10),
            _MetricWidget(
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
          "Secondary Muscle: ${widget.exercise.secondaryMuscles.isNotEmpty ? widget.exercise.secondaryMuscles.join(", ") : "None"}",
          style: GoogleFonts.lato(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500, fontSize: 12),
        )
      ],
    );
  }

  void _loadChart() {
    _routineLogs = widget.routineLogs.reversed.toList();

    _dateTimes =
        widget.routineLogs.map((log) => dateTimePerLog(log: log).formattedDayAndMonth()).toList().reversed.toList();
    _heaviestWeights();
  }

  @override
  void initState() {
    super.initState();
    _loadChart();
  }
}

class _MetricWidget extends StatelessWidget {
  const _MetricWidget({
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

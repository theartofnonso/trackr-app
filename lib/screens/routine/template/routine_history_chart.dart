import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/screens/routine/template/routine_preview_screen.dart';
import 'package:tracker_app/utils/datetime_utils.dart';

import '../../../app_constants.dart';
import '../../../dtos/graph/chart_point_dto.dart';
import '../../../enums.dart';
import '../../../models/RoutineLog.dart';
import '../../../providers/routine_log_provider.dart';
import '../../../widgets/buttons/text_button_widget.dart';
import '../../../widgets/chart/line_chart_widget.dart';
import '../../../widgets/empty_states/bar_chart_empty_state.dart';
import '../../exercise/exercise_history_screen.dart';

class RoutineHistoryChart extends StatefulWidget {
  final String routineId;

  const RoutineHistoryChart({super.key, required this.routineId});

  @override
  State<RoutineHistoryChart> createState() => _RoutineHistoryChartState();
}

class _RoutineHistoryChartState extends State<RoutineHistoryChart> {
  List<RoutineLog> _logs = [];

  List<RoutineLog> _filteredLogs = [];

  List<String> _dateTimes = [];

  List<ChartPointDto> _chartPoints = [];

  late ChartUnit _chartUnit;

  RoutineSummaryType _summaryType = RoutineSummaryType.volume;

  HistoricalTimePeriod _selectedHistoricalDate = HistoricalTimePeriod.allTime;

  @override
  void initState() {
    super.initState();
    _loadChart();
  }

  void _volume() {
    final values = _filteredLogs.map((log) => volumePerLog(log: log)).toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = RoutineSummaryType.volume;
      _chartUnit = weightUnit();
    });
  }

  void _totalReps() {
    final values = _filteredLogs.map((log) => repsPerLog(log: log)).toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = RoutineSummaryType.reps;
      _chartUnit = ChartUnit.reps;
    });
  }

  void _totalDuration() {
    final values = _filteredLogs.map((log) => durationPerLog(log: log)).toList();
    setState(() {
      _chartPoints =
          values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.inMinutes.toDouble())).toList();
      _summaryType = RoutineSummaryType.duration;
      _chartUnit = ChartUnit.min;
    });
  }

  void _recomputeChart() {
    switch (_selectedHistoricalDate) {
      case HistoricalTimePeriod.lastThreeMonths:
        _filteredLogs =
            Provider.of<RoutineLogProvider>(context, listen: false).routineLogsSince(90, logs: _logs).toList();
      case HistoricalTimePeriod.lastOneYear:
        _filteredLogs =
            Provider.of<RoutineLogProvider>(context, listen: false).routineLogsSince(365, logs: _logs).toList();
      case HistoricalTimePeriod.allTime:
        _filteredLogs = _logs.toList();
    }

    _dateTimes = _logs.map((log) => dateTimePerLog(log: log).formattedDayAndMonth()).toList();

    switch (_summaryType) {
      case RoutineSummaryType.volume:
        _volume();
      case RoutineSummaryType.reps:
        _totalReps();
      case RoutineSummaryType.duration:
        _totalDuration();
    }
  }

  Color? _buttonColor({required RoutineSummaryType type}) {
    return _summaryType == type ? Colors.blueAccent : tealBlueLight;
  }

  void _loadChart() {
    Provider.of<RoutineLogProvider>(context, listen: false)
        .listRoutineLogsForRoutine(id: widget.routineId)
        .then((logs) async {
      _logs = logs.reversed.toList();
      _filteredLogs = _logs;
      _dateTimes = logs.map((log) => dateTimePerLog(log: log).formattedDayAndMonth()).toList();
      _volume();
    });
    _chartUnit = weightUnit(); // Initial unit
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<RoutineLogProvider>(context, listen: true);
    return _chartPoints.isNotEmpty
        ? Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0, right: 20, bottom: 10),
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
                          .map<DropdownMenuItem<String>>((HistoricalTimePeriod historicalTimePeriod) {
                        return DropdownMenuItem<String>(
                          value: historicalTimePeriod.label,
                          child: Text(historicalTimePeriod.label, style: GoogleFonts.lato(fontSize: 12)),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CTextButton(
                    onPressed: _volume,
                    label: "Volume",
                    buttonColor: _buttonColor(type: RoutineSummaryType.volume),
                  ),
                  const SizedBox(width: 5),
                  CTextButton(
                    onPressed: _totalReps,
                    label: "Reps",
                    buttonColor: _buttonColor(type: RoutineSummaryType.reps),
                  ),
                  const SizedBox(width: 5),
                  CTextButton(
                    onPressed: _totalDuration,
                    label: "Duration",
                    buttonColor: _buttonColor(type: RoutineSummaryType.duration),
                  ),
                ],
              ),
            ],
          )
        : const BarChartEmptyState();
  }
}

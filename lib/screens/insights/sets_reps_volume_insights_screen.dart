import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/enums/chart_period_enum.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/utils/general_utils.dart';

import '../../colors.dart';
import '../../controllers/routine_log_controller.dart';
import '../../dtos/graph/chart_point_dto.dart';
import '../../dtos/set_dto.dart';
import '../../enums/chart_unit_enum.dart';
import '../../enums/muscle_group_enums.dart';
import '../../enums/sets_reps_volume_enum.dart';
import '../../health_and_fitness_stats.dart';
import '../../utils/exercise_logs_utils.dart';
import '../../widgets/calendar/calendar_navigator.dart';
import '../../widgets/chart/bar_chart.dart';
import '../../widgets/chart/legend.dart';

class SetsAndRepsVolumeInsightsScreen extends StatefulWidget {
  const SetsAndRepsVolumeInsightsScreen({super.key});

  @override
  State<SetsAndRepsVolumeInsightsScreen> createState() => _SetsAndRepsVolumeInsightsScreenState();
}

class _SetsAndRepsVolumeInsightsScreenState extends State<SetsAndRepsVolumeInsightsScreen> {
  late DateTimeRange _dateTimeRange;

  ChartPeriod _period = ChartPeriod.month;
  SetRepsVolumeReps _metric = SetRepsVolumeReps.sets;

  late MuscleGroupFamily _selectedMuscleGroupFamily;

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white70);

    final muscleGroups = popularMuscleGroupFamilies();

    final routineLogController = Provider.of<RoutineLogController>(context, listen: false);

    final periodicalLogs = _period == ChartPeriod.month
        ? routineLogController.weeklyLogs.entries
            .where((weekEntry) => weekEntry.key.start.month == _dateTimeRange.start.month)
        : routineLogController.weeklyLogs.entries.where((weekEntry) =>
            weekEntry.key.start.isAfterOrEqual(_dateTimeRange.start) &&
            weekEntry.key.end.isBeforeOrEqual(_dateTimeRange.end));

    List<num> periodicalValues = [];

    for (final periodAndLogs in periodicalLogs) {
      final valuesForPeriod = periodAndLogs.value
          .map((log) => exerciseLogsWithCheckedSets(exerciseLogs: log.exerciseLogs))
          .expand((exerciseLogs) => exerciseLogs)
          .where((exerciseLog) => exerciseLog.exercise.primaryMuscleGroup.family == _selectedMuscleGroupFamily)
          .map((log) {
        final values = _calculateMetric(sets: log.sets);
        return values;
      }).sum;

      periodicalValues.add(valuesForPeriod);
    }

    final avgValue = periodicalValues.isNotEmpty ? periodicalValues.where((value) => value > 0).average.round() : 0;

    final chartPoints =
        periodicalValues.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();

    final periods = periodicalValues.mapIndexed((index, monthEntry) {
      return "WK ${index + 1}";
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: sapphireDark80,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Muscle Trend".toUpperCase(),
            style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              sapphireDark80,
              sapphireDark,
            ],
          ),
        ),
        child: SafeArea(
          minimum: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                decoration: BoxDecoration(
                  color: sapphireDark.withOpacity(0.6), // Background color
                  borderRadius: BorderRadius.circular(5), // Border radius
                ),
                child: DropdownButton<MuscleGroupFamily>(
                  menuMaxHeight: 400,
                  isExpanded: true,
                  isDense: true,
                  value: _selectedMuscleGroupFamily,
                  hint: Text("Muscle group",
                      style: GoogleFonts.montserrat(color: Colors.white70, fontWeight: FontWeight.w500, fontSize: 14)),
                  underline: Container(
                    color: Colors.transparent,
                  ),
                  style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
                  onChanged: (MuscleGroupFamily? value) {
                    if (value != null) {
                      setState(() {
                        _selectedMuscleGroupFamily = value;
                      });
                    }
                  },
                  items: muscleGroups.map<DropdownMenuItem<MuscleGroupFamily>>((MuscleGroupFamily muscleGroup) {
                    return DropdownMenuItem<MuscleGroupFamily>(
                      value: muscleGroup,
                      child: Text(muscleGroup.name,
                          style: GoogleFonts.montserrat(
                              color: _selectedMuscleGroupFamily == muscleGroup ? Colors.white : Colors.white70,
                              fontWeight: _selectedMuscleGroupFamily == muscleGroup ? FontWeight.bold : FontWeight.w500,
                              fontSize: 14)),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              CupertinoSlidingSegmentedControl<ChartPeriod>(
                backgroundColor: sapphireDark,
                thumbColor: sapphireLight,
                groupValue: _period,
                children: {
                  ChartPeriod.month: SizedBox(
                      width: 30,
                      child: Text(ChartPeriod.month.name.toUpperCase(), style: textStyle, textAlign: TextAlign.center)),
                  ChartPeriod.threeMonths: SizedBox(
                      width: 30,
                      child: Text(ChartPeriod.threeMonths.name.toUpperCase(),
                          style: textStyle, textAlign: TextAlign.center)),
                },
                onValueChanged: (ChartPeriod? value) {
                  if (value != null) {
                    setState(() {
                      _period = value;
                      _dateTimeRange = _periodDateTimeRange();
                    });
                  }
                },
              ),
              CalendarNavigator(
                onChangedDateTimeRange: _onChangedDateTimeRange,
                chartPeriod: _period,
                dateTimeRange: _dateTimeRange,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: "$avgValue",
                          style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 28),
                          children: [
                            TextSpan(
                              text: " ",
                              style: GoogleFonts.montserrat(
                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            TextSpan(
                              text: _metricLabel().toUpperCase(),
                              style: GoogleFonts.montserrat(
                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "WEEKLY AVERAGE",
                        style: GoogleFonts.montserrat(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: sapphireDark,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "past week",
                              style: GoogleFonts.montserrat(
                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  CupertinoSlidingSegmentedControl<SetRepsVolumeReps>(
                    backgroundColor: sapphireDark,
                    thumbColor: sapphireLight,
                    groupValue: _metric,
                    children: {
                      SetRepsVolumeReps.sets: SizedBox(
                          width: 40,
                          child: Text(SetRepsVolumeReps.sets.name, style: textStyle, textAlign: TextAlign.center)),
                      SetRepsVolumeReps.reps: SizedBox(
                          width: 40,
                          child: Text(SetRepsVolumeReps.reps.name, style: textStyle, textAlign: TextAlign.center)),
                      SetRepsVolumeReps.volume: SizedBox(
                          width: 40,
                          child: Text(SetRepsVolumeReps.volume.name, style: textStyle, textAlign: TextAlign.center)),
                    },
                    onValueChanged: (SetRepsVolumeReps? value) {
                      if (value != null) {
                        setState(() {
                          _metric = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 60),
              SizedBox(
                  height: 200,
                  child: CustomBarChart(
                    chartPoints: chartPoints,
                    periods: periods,
                    unit: _chartUnit(),
                    minify: _period == ChartPeriod.threeMonths,
                    extraLinesData: _isRepsOrSetsMetric()
                        ? ExtraLinesData(
                            horizontalLines: [
                              HorizontalLine(
                                y: _averageMaximumWeeklyValue(),
                                color: vibrantGreen,
                                strokeWidth: 1.5,
                                strokeCap: StrokeCap.round,
                                dashArray: [10],
                                label: HorizontalLineLabel(
                                  show: true,
                                  alignment: Alignment.topRight,
                                  style: GoogleFonts.montserrat(
                                      color: vibrantGreen, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                              HorizontalLine(
                                y: _averageMedianWeeklyValue(),
                                color: vibrantBlue,
                                strokeWidth: 1.5,
                                dashArray: [10],
                                strokeCap: StrokeCap.round,
                                // dashArray: [1],
                                label: HorizontalLineLabel(
                                  show: true,
                                  alignment: Alignment.topRight,
                                  style: GoogleFonts.montserrat(
                                      color: vibrantBlue, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                              HorizontalLine(
                                y: _averageMinimumWeeklyValue(),
                                color: Colors.red,
                                strokeWidth: 1.5,
                                strokeCap: StrokeCap.round,
                                dashArray: [10],
                                label: HorizontalLineLabel(
                                  show: true,
                                  alignment: Alignment.topRight,
                                  style: GoogleFonts.montserrat(
                                      color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          )
                        : null,
                  )),
              const SizedBox(height: 20),
              if (_isRepsOrSetsMetric())
                Column(children: [
                  Legend(
                    title: "${_averageMinimumWeeklyValue().toInt()}", //
                    suffix: "x",
                    subTitle: 'Minimum',
                    color: Colors.red,
                  ),
                  const SizedBox(height: 6),
                  Legend(
                    title: "${_averageMedianWeeklyValue().toInt()}",
                    suffix: "x",
                    subTitle: 'Sufficient',
                    color: vibrantBlue,
                  ),
                  const SizedBox(height: 6),
                  Legend(
                    title: "${_averageMaximumWeeklyValue().toInt()}",
                    suffix: "x",
                    subTitle: 'Optimal',
                    color: vibrantGreen,
                  ),
                ])
            ],
          ),
        ),
      ),
    );
  }

  DateTime toFirstDayOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  void _onChangedDateTimeRange(DateTimeRange? range) {
    if (range == null) return;
    setState(() {
      _dateTimeRange = range;
    });
  }

  num _calculateMetric({required List<SetDto> sets}) {
    return switch (_metric) {
      SetRepsVolumeReps.sets => sets.length,
      SetRepsVolumeReps.reps => sets.map((set) => set.repsValue()).sum,
      SetRepsVolumeReps.volume => sets.map((set) => set.volume()).sum,
    };
  }

  bool _isRepsOrSetsMetric() {
    return _metric == SetRepsVolumeReps.sets || _metric == SetRepsVolumeReps.reps;
  }

  ChartUnit _chartUnit() {
    return switch (_metric) {
      SetRepsVolumeReps.sets => ChartUnit.number,
      SetRepsVolumeReps.reps => ChartUnit.number,
      SetRepsVolumeReps.volume => ChartUnit.weight,
    };
  }

  String _metricLabel() {
    final unit = _chartUnit();
    return switch (unit) {
      ChartUnit.number => _metric.name,
      ChartUnit.weight => weightLabel(),
      ChartUnit.duration => "",
    };
  }

  double _averageMinimumWeeklyValue() {
    if (_metric == SetRepsVolumeReps.sets) {
      return averageMinimumWeeklySets.toDouble();
    } else {
      return averageMinimumWeeklyReps.toDouble();
    }
  }

  double _averageMaximumWeeklyValue() {
    if (_metric == SetRepsVolumeReps.sets) {
      return averageMaximumWeeklySets.toDouble();
    } else {
      return averageMaximumWeeklyReps.toDouble();
    }
  }

  double _averageMedianWeeklyValue() {
    if (_metric == SetRepsVolumeReps.sets) {
      return averageMedianWeeklySets.toDouble();
    } else {
      return averageMedianWeeklyReps.toDouble();
    }
  }

  DateTimeRange _periodDateTimeRange() {
    final now = DateTime.now();
    return switch (_period) {
      ChartPeriod.month => thisMonthDateRange(),
      ChartPeriod.threeMonths => DateTimeRange(start: now.previous90Days(), end: now.lastWeekDay().dateOnly()),
    };
  }

  @override
  void initState() {
    super.initState();
    _selectedMuscleGroupFamily = popularMuscleGroupFamilies().first;
    _dateTimeRange = thisMonthDateRange();
  }
}

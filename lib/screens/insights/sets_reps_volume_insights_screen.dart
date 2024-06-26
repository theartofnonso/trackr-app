import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/enums/chart_period_enum.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/extensions/routine_log_extension.dart';
import 'package:tracker_app/utils/general_utils.dart';
import 'package:tracker_app/utils/string_utils.dart';
import 'package:tracker_app/widgets/empty_states/horizontal_stacked_bars_empty_state.dart';

import '../../colors.dart';
import '../../controllers/routine_log_controller.dart';
import '../../dtos/graph/chart_point_dto.dart';
import '../../dtos/routine_log_dto.dart';
import '../../dtos/set_dto.dart';
import '../../enums/chart_unit_enum.dart';
import '../../enums/muscle_group_enums.dart';
import '../../enums/sets_reps_volume_enum.dart';
import '../../utils/exercise_logs_utils.dart';
import '../../utils/routine_utils.dart';
import '../../widgets/backgrounds/overlay_background.dart';
import '../../widgets/calendar/calendar_months_navigator.dart';
import '../../widgets/chart/bar_chart.dart';
import '../../widgets/chart/horizontal_stacked_bars.dart';
import '../../widgets/chart/legend.dart';

class SetsAndRepsVolumeInsightsScreen extends StatefulWidget {
  static const routeName = '/sets_and_reps_volume_insights_screen';

  const SetsAndRepsVolumeInsightsScreen({super.key});

  @override
  State<SetsAndRepsVolumeInsightsScreen> createState() => _SetsAndRepsVolumeInsightsScreenState();
}

class _SetsAndRepsVolumeInsightsScreenState extends State<SetsAndRepsVolumeInsightsScreen> {
  Map<DateTimeRange, List<RoutineLogDto>>? _weeklyLogs;

  late DateTimeRange _dateTimeRange;

  ChartPeriod _period = ChartPeriod.month;
  SetRepsVolumeReps _metric = SetRepsVolumeReps.sets;

  late MuscleGroup _selectedMuscleGroup;

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white70);

    const muscleGroups = MuscleGroup.values;

    final routineLogController = Provider.of<RoutineLogController>(context, listen: false);

    final logsForTheWeek = _weeklyLogs ?? routineLogController.weeklyLogs;

    final periodicalLogs = _period == ChartPeriod.month
        ? logsForTheWeek.entries.where((weekEntry) =>
            weekEntry.key.start.month == _dateTimeRange.start.month ||
            weekEntry.key.end.month == _dateTimeRange.start.month)
        : logsForTheWeek.entries.where((weekEntry) =>
            weekEntry.key.start.isAfterOrEqual(_dateTimeRange.start) &&
            weekEntry.key.end.isBeforeOrEqual(_dateTimeRange.end));

    List<num> periodicalValues = [];
    List<DateTime> periodicalDates = [];

    for (final periodAndLogs in periodicalLogs) {
      final valuesForPeriod = periodAndLogs.value
          .map((log) => exerciseLogsWithCheckedSets(exerciseLogs: log.exerciseLogs))
          .expand((exerciseLogs) => exerciseLogs)
          .where((exerciseLog) => exerciseLog.exercise.primaryMuscleGroup == _selectedMuscleGroup)
          .map((log) {
        final values = _calculateMetric(sets: log.sets);
        return values;
      }).sum;

      periodicalValues.add(valuesForPeriod);
      periodicalDates.add(periodAndLogs.key.end);
    }

    final nonZeroValues = periodicalValues.where((value) => value > 0).toList();

    final avgValue = nonZeroValues.isNotEmpty ? nonZeroValues.average.round() : 0;

    final chartPoints =
        periodicalValues.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();

    final weeks = periodicalValues.mapIndexed((index, _) {
      return "WK ${index + 1}";
    }).toList();

    final months = periodicalDates.map((date) => date.formattedMonth()).toList();

    final totalOptimal = _weightWhere(values: nonZeroValues, condition: (value) => value >= _optimalSetsOrRepsValue());
    final totalSufficient = _weightWhere(
        values: nonZeroValues,
        condition: (value) => value >= _sufficientSetsOrRepsValue() && value < _optimalSetsOrRepsValue());
    final totalMinimum = _weightWhere(
        values: nonZeroValues,
        condition: (value) => value >= _minimumSetsOrRepsValue() && value < _sufficientSetsOrRepsValue());

    final weights = [totalOptimal, totalSufficient, totalMinimum];

    final hasWeights = weights.any((weight) => weight > 0);

    final weightColors = [vibrantGreen, vibrantBlue, Colors.orange];

    final barColors = periodicalValues
        .map((value) => _metric == SetRepsVolumeReps.sets
            ? setsTrendColor(sets: value.toInt())
            : repsTrendColor(reps: value.toInt()))
        .toList();

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
        width: double.infinity,
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
        child: Stack(children: [
          SafeArea(
            minimum: const EdgeInsets.all(10),
            child: SingleChildScrollView(
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
                    child: DropdownButton<MuscleGroup>(
                      menuMaxHeight: 200,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(8),
                      isDense: true,
                      value: _selectedMuscleGroup,
                      hint: Text("Muscle group",
                          style:
                              GoogleFonts.montserrat(color: Colors.white70, fontWeight: FontWeight.w500, fontSize: 14)),
                      underline: Container(
                        color: Colors.transparent,
                      ),
                      style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
                      onChanged: (MuscleGroup? value) {
                        if (value != null) {
                          setState(() {
                            _selectedMuscleGroup = value;
                          });
                        }
                      },
                      items: muscleGroups.map<DropdownMenuItem<MuscleGroup>>((MuscleGroup muscleGroup) {
                        return DropdownMenuItem<MuscleGroup>(
                          value: muscleGroup,
                          child: Text(muscleGroup.name,
                              style: GoogleFonts.montserrat(
                                  color: _selectedMuscleGroup == muscleGroup ? Colors.white : Colors.white70,
                                  fontWeight: _selectedMuscleGroup == muscleGroup ? FontWeight.bold : FontWeight.w500,
                                  fontSize: 14)),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  CalendarMonthsNavigator(
                    onChangedDateTimeRange: _onChangedDateTimeRange,
                    chartPeriod: _period,
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
                              text:
                                  "${_metric == SetRepsVolumeReps.volume ? volumeInKOrM(avgValue.toDouble(), showLessThan1k: false) : avgValue}",
                              style: GoogleFonts.montserrat(
                                  color: Colors.white, fontWeight: FontWeight.w700, fontSize: 28),
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
                            style: GoogleFonts.montserrat(
                                color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 10),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          CupertinoSlidingSegmentedControl<ChartPeriod>(
                            backgroundColor: sapphireDark,
                            thumbColor: sapphireLight,
                            groupValue: _period,
                            children: {
                              ChartPeriod.month: SizedBox(
                                  width: 40,
                                  child: Text(ChartPeriod.month.name.toUpperCase(),
                                      style: textStyle, textAlign: TextAlign.center)),
                              ChartPeriod.threeMonths: SizedBox(
                                  width: 40,
                                  child: Text(ChartPeriod.threeMonths.name.toUpperCase(),
                                      style: textStyle, textAlign: TextAlign.center)),
                              ChartPeriod.sixMonths: SizedBox(
                                  width: 40,
                                  child: Text(ChartPeriod.sixMonths.name.toUpperCase(),
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
                          const SizedBox(height: 10),
                          CupertinoSlidingSegmentedControl<SetRepsVolumeReps>(
                            backgroundColor: sapphireDark,
                            thumbColor: sapphireLight,
                            groupValue: _metric,
                            children: {
                              SetRepsVolumeReps.sets: SizedBox(
                                  width: 40,
                                  child:
                                      Text(SetRepsVolumeReps.sets.name, style: textStyle, textAlign: TextAlign.center)),
                              SetRepsVolumeReps.reps: SizedBox(
                                  width: 40,
                                  child:
                                      Text(SetRepsVolumeReps.reps.name, style: textStyle, textAlign: TextAlign.center)),
                              SetRepsVolumeReps.volume: SizedBox(
                                  width: 40,
                                  child: Text(SetRepsVolumeReps.volume.name,
                                      style: textStyle, textAlign: TextAlign.center)),
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
                    ],
                  ),
                  const SizedBox(height: 60),
                  SizedBox(
                      height: 250,
                      child: CustomBarChart(
                        chartPoints: chartPoints,
                        periods: _period == ChartPeriod.month ? weeks : months,
                        barColors: _metric != SetRepsVolumeReps.volume ? barColors : null,
                        unit: _chartUnit(),
                        bottomTitlesInterval: _period == ChartPeriod.month
                            ? 1
                            : weeks.length > 7
                                ? 4
                                : 2,
                        showTopTitles: _period == ChartPeriod.month ? true : false,
                        showLeftTitles: true,
                        reservedSize: _reservedSize(),
                      )),
                  const SizedBox(height: 10),
                  if (_isRepsOrSetsMetric())
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        "${_metric.name} Breakdown".toUpperCase(),
                        style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                      const SizedBox(height: 14),
                      hasWeights
                          ? HorizontalStackedBars(weights: weights, colors: weightColors)
                          : const HorizontalStackedBarsEmptyState(),
                      const SizedBox(height: 10),
                      Legend(
                        title: "$totalOptimal",
                        suffix: "x",
                        subTitle: 'Optimal (>${_optimalSetsOrRepsValue()} ${_metric.name})',
                        color: vibrantGreen,
                      ),
                      const SizedBox(height: 6),
                      Legend(
                        title: "$totalSufficient",
                        suffix: "x",
                        subTitle:
                            'Sufficient (${_sufficientSetsOrRepsValue()}-${_optimalSetsOrRepsValue()} ${_metric.name})',
                        color: vibrantBlue,
                      ),
                      const SizedBox(height: 6),
                      Legend(
                        title: "$totalMinimum", //
                        suffix: "x",
                        subTitle: 'Minimum (<${_sufficientSetsOrRepsValue()} ${_metric.name})',
                        color: Colors.orange,
                      ),
                    ])
                ],
              ),
            ),
          ),
          if (_loading) const OverlayBackground(opacity: 0.9)
        ]),
      ),
    );
  }

  // void _onChangedDateTimeRange(DateTimeRange? range) {
  //   if (range == null) return;
  //   setState(() {
  //     _dateTimeRange = range;
  //   });
  // }

  void _onChangedDateTimeRange(DateTimeRange? range) {
    if (range == null) return;

    final isDifferentYear = !_dateTimeRange.start.isSameYear(range.start);

    setState(() {
      _loading = isDifferentYear;
    });

    final routineLogController = Provider.of<RoutineLogController>(context, listen: false);

    if (isDifferentYear) {
      routineLogController.fetchLogsCloud(range: range.start.dateTimeRange()).then((logs) {
        setState(() {
          _loading = false;
          final dtos = logs.map((log) => log.dto()).sorted((a, b) => a.createdAt.compareTo(b.createdAt));
          _weeklyLogs = groupRoutineLogsByWeek(routineLogs: dtos);
        });
      });
    }

    setState(() {
      _dateTimeRange = range;
    });
  }

  int _weightWhere({required List<num> values, required bool Function(num) condition}) {
    return values.where(condition).length;
  }

  DateTime toFirstDayOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  num _calculateMetric({required List<SetDto> sets}) {
    return switch (_metric) {
      SetRepsVolumeReps.sets => sets.length,
      SetRepsVolumeReps.reps => sets.map((set) => set.repsValue()).sum,
      SetRepsVolumeReps.volume => sets.map((set) => set.volume()).sum,
    };
  }

  double _reservedSize() {
    return switch (_metric) {
      SetRepsVolumeReps.sets => 20,
      SetRepsVolumeReps.reps => 35,
      SetRepsVolumeReps.volume => 40,
    };
  }

  bool _isRepsOrSetsMetric() {
    return _metric == SetRepsVolumeReps.sets || _metric == SetRepsVolumeReps.reps;
  }

  int _minimumSetsOrRepsValue() {
    return _metric == SetRepsVolumeReps.sets ? 3 : 30;
  }

  int _sufficientSetsOrRepsValue() {
    return _metric == SetRepsVolumeReps.sets ? 6 : 60;
  }

  int _optimalSetsOrRepsValue() {
    return _metric == SetRepsVolumeReps.sets ? 12 : 120;
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

  DateTimeRange _periodDateTimeRange() {
    final now = DateTime.now();
    return switch (_period) {
      ChartPeriod.month => thisMonthDateRange(),
      ChartPeriod.threeMonths => DateTimeRange(start: now.past90Days(), end: now.lastWeekDay().withoutTime()),
      ChartPeriod.sixMonths => DateTimeRange(start: now.past180Days(), end: now.lastWeekDay().withoutTime()),
    };
  }

  @override
  void initState() {
    super.initState();
    final defaultMuscleGroup = Provider.of<RoutineLogController>(context, listen: false)
        .routineLogs
        .firstOrNull
        ?.exerciseLogs
        .firstOrNull
        ?.exercise
        .primaryMuscleGroup;
    _selectedMuscleGroup = defaultMuscleGroup ?? MuscleGroup.values.first;
    _dateTimeRange = thisMonthDateRange();
  }
}

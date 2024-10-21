import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/extensions/routine_log_extension.dart';
import 'package:tracker_app/utils/dialog_utils.dart';
import 'package:tracker_app/utils/general_utils.dart';
import 'package:tracker_app/utils/string_utils.dart';
import 'package:tracker_app/widgets/empty_states/horizontal_stacked_bars_empty_state.dart';

import '../../colors.dart';
import '../../controllers/exercise_controller.dart';
import '../../controllers/routine_log_controller.dart';
import '../../dtos/graph/chart_point_dto.dart';
import '../../dtos/routine_log_dto.dart';
import '../../dtos/set_dto.dart';
import '../../enums/chart_unit_enum.dart';
import '../../enums/muscle_group_enums.dart';
import '../../enums/sets_reps_volume_enum.dart';
import '../../openAI/open_ai.dart';
import '../../strings/ai_prompts.dart';
import '../../utils/exercise_logs_utils.dart';
import '../../utils/navigation_utils.dart';
import '../../utils/routine_utils.dart';
import '../../widgets/ai_widgets/trkr_information_container.dart';
import '../../widgets/backgrounds/trkr_loading_screen.dart';
import '../../widgets/calendar/calendar_navigator.dart';
import '../../widgets/chart/bar_chart.dart';
import '../../widgets/chart/horizontal_stacked_bars.dart';
import '../../widgets/chart/legend.dart';
import '../AI/trkr_coach_summary_screen.dart';

class SetsAndRepsVolumeInsightsScreen extends StatefulWidget {
  static const routeName = '/sets_and_reps_volume_insights_screen';

  const SetsAndRepsVolumeInsightsScreen({super.key});

  @override
  State<SetsAndRepsVolumeInsightsScreen> createState() => _SetsAndRepsVolumeInsightsScreenState();
}

class _SetsAndRepsVolumeInsightsScreenState extends State<SetsAndRepsVolumeInsightsScreen> {
  Map<DateTimeRange, List<RoutineLogDto>>? _monthlyLogs;

  SetRepsVolumeReps _metric = SetRepsVolumeReps.sets;

  late MuscleGroup _selectedMuscleGroup;

  bool _loading = false;

  late DateTimeRange _monthDateTimeRange;

  @override
  Widget build(BuildContext context) {
    if (_loading) return TRKRLoadingScreen(action: _hideLoadingScreen);

    final textStyle = GoogleFonts.ubuntu(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white70);

    final muscleGroups = MuscleGroup.values;

    final routineLogController = Provider.of<RoutineLogController>(context, listen: false);

    final logs = _monthlyLogs?[_monthDateTimeRange] ?? routineLogController.monthlyLogs[_monthDateTimeRange] ?? [];

    final exerciseController = Provider.of<ExerciseController>(context, listen: false);

    final exerciseLogs = logs
        .expand((routineLog) => exerciseLogsWithCheckedSets(exerciseLogs: routineLog.exerciseLogs))
        .map((exerciseLog) {
      final foundExercise =
          exerciseController.exercises.firstWhereOrNull((exerciseInLibrary) => exerciseInLibrary.id == exerciseLog.id);
      return foundExercise != null ? exerciseLog.copyWith(exercise: foundExercise) : exerciseLog;
    }).where((exerciseLog) {
      final muscleGroups = [exerciseLog.exercise.primaryMuscleGroup, ...exerciseLog.exercise.secondaryMuscleGroups];
      return muscleGroups.contains(_selectedMuscleGroup);
    }).toList();

    List<num> periodicalValues = [];
    List<DateTime> periodicalDates = [];

    for (final exerciseLog in exerciseLogs) {
      final value = _calculateMetric(sets: exerciseLog.sets);
      periodicalValues.add(value);
      periodicalDates.add(exerciseLog.createdAt);
    }

    final nonZeroValues = periodicalValues.where((value) => value > 0).toList();

    final avgValue = nonZeroValues.isNotEmpty ? nonZeroValues.average.round() : 0;

    final chartPoints =
        periodicalValues.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();

    final months = periodicalDates.map((date) => date.formattedMonth()).toList();

    final totalOptimal = _weightWhere(values: nonZeroValues, condition: (value) => value >= _optimalSetsOrRepsValue());
    final totalSufficient = _weightWhere(
        values: nonZeroValues,
        condition: (value) => value >= _sufficientSetsOrRepsValue() && value < _optimalSetsOrRepsValue());
    final totalMinimum =
        _weightWhere(values: nonZeroValues, condition: (value) => value < _sufficientSetsOrRepsValue());

    final weights = [totalOptimal, totalSufficient, totalMinimum];

    final hasWeights = weights.any((weight) => weight > 0);

    final weightColors = [vibrantGreen, vibrantBlue, Colors.deepOrangeAccent];

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
          onPressed: context.pop,
        ),
        title: Text("Muscle Trend".toUpperCase(),
            style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
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
        child: SafeArea(
          minimum: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CalendarNavigator(
                  onYearChange: _onYearChange,
                  onMonthChange: _onMonthChange,
                  onWeeksInYearChange: (List<DateTimeRange> weeksInYear) {},
                  onWeeksInMonthChange: (List<DateTimeRange> weeksInMonth) {},
                ),
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
                        style: GoogleFonts.ubuntu(color: Colors.white70, fontWeight: FontWeight.w500, fontSize: 14)),
                    underline: Container(
                      color: Colors.transparent,
                    ),
                    style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
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
                            style: GoogleFonts.ubuntu(
                                color: _selectedMuscleGroup == muscleGroup ? Colors.white : Colors.white70,
                                fontWeight: _selectedMuscleGroup == muscleGroup ? FontWeight.bold : FontWeight.w500,
                                fontSize: 14)),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                TRKRInformationContainer(
                  ctaLabel: "Review your ${_selectedMuscleGroup.name} training",
                  description: _selectedMuscleGroup.description,
                  onTap: () => _generateSummary(logs: exerciseLogs),
                ),
                const SizedBox(height: 12),
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
                            style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 28),
                            children: [
                              TextSpan(
                                text: " ",
                                style:
                                    GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              TextSpan(
                                text: _metricLabel().toUpperCase(),
                                style:
                                    GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "WEEKLY AVERAGE",
                          style: GoogleFonts.ubuntu(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 10),
                        ),
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
                    height: 250,
                    child: CustomBarChart(
                      chartPoints: chartPoints,
                      periods: months,
                      barColors: _metric != SetRepsVolumeReps.volume ? barColors : null,
                      unit: _chartUnit(),
                      bottomTitlesInterval: 6,
                      showTopTitles: false,
                      showLeftTitles: true,
                      reservedSize: _reservedSize(),
                    )),
                const SizedBox(height: 10),
                if (_isRepsOrSetsMetric())
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      "${_metric.name} Breakdown".toUpperCase(),
                      style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
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
                      color: Colors.deepOrangeAccent,
                    ),
                  ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLoadingScreen() {
    setState(() {
      _loading = true;
    });
  }

  void _hideLoadingScreen() {
    setState(() {
      _loading = false;
    });
  }

  void _generateSummary({required List<ExerciseLogDto> logs}) {
    if (logs.isEmpty) {
      showSnackbar(
          context: context, icon: const FaIcon(FontAwesomeIcons.circleInfo), message: "You don't have any logs");
    } else {
      final userInstructions =
          "Review my workout logs for ${_selectedMuscleGroup.name} from ${_monthDateTimeRange.start} to ${_monthDateTimeRange.end} and provide feedback";

      final logJsons = logs.map((log) => log.toJson());

      final StringBuffer buffer = StringBuffer();

      buffer.writeln(userInstructions);
      buffer.writeln(logJsons);

      final completeInstructions = buffer.toString();

      _showLoadingScreen();

      runMessage(system: routineLogSystemInstruction, user: completeInstructions).then((response) {
        _hideLoadingScreen();
        if (mounted) {
          if (response != null) {
            navigateWithSlideTransition(context: context, child: TRKRCoachSummaryScreen(content: response));
          }
        }
      });
    }
  }

  void _onYearChange(DateTimeRange range) {
    _showLoadingScreen();

    final routineLogController = Provider.of<RoutineLogController>(context, listen: false);

    routineLogController.fetchLogsCloud(range: range.start.dateTimeRange()).then((logs) {
      setState(() {
        final dtos = logs.map((log) => log.dto()).sorted((a, b) => a.createdAt.compareTo(b.createdAt));
        _monthlyLogs = groupRoutineLogsByMonth(routineLogs: dtos);
      });
    });

    _hideLoadingScreen();
  }

  void _onMonthChange(DateTimeRange range) {
    setState(() {
      _monthDateTimeRange = range;
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
    _monthDateTimeRange = thisMonthDateRange();
  }
}

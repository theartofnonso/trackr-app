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
import 'package:tracker_app/utils/date_utils.dart';
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
  DateTime _dateTime = DateTime.now();

  List<RoutineLogDto>? _logs;

  SetRepsVolumeReps _metric = SetRepsVolumeReps.reps;

  MuscleGroup _selectedMuscleGroup = MuscleGroup.abs;

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    if (_loading) return TRKRLoadingScreen(action: _hideLoadingScreen);

    final textStyle = GoogleFonts.ubuntu(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white70);

    final routineLogController = Provider.of<RoutineLogController>(context, listen: false);

    final logs = _logs ?? routineLogController.whereLogsIsSameMonth(dateTime: _dateTime);

    final exerciseController = Provider.of<ExerciseController>(context, listen: false);

    final exerciseLogs = logs
        .map((log) => exerciseLogsWithCheckedSets(exerciseLogs: log.exerciseLogs))
        .expand((exerciseLogs) => exerciseLogs)
        .map((exerciseLog) {
      final foundExercise = exerciseController.exercises
          .firstWhereOrNull((exerciseInLibrary) => exerciseInLibrary.id == exerciseLog.exercise.id);
      return foundExercise != null ? exerciseLog.copyWith(exercise: foundExercise) : exerciseLog;
    }).where((exerciseLog) {
      final muscleGroups = [exerciseLog.exercise.primaryMuscleGroup, ...exerciseLog.exercise.secondaryMuscleGroups];
      return muscleGroups.contains(_selectedMuscleGroup);
    }).toList();

    final weeksInMonth = generateWeeksInMonth(_dateTime);
    List<num> valuesForWeek = [];
    List<int> weeks = [];
    int weekCounter = 0;
    for (final week in weeksInMonth) {
      final startOfWeek = week.start;
      final endOfWeek = week.end;
      final values = exerciseLogs
          .where((exerciseLog) => exerciseLog.createdAt.isBetweenInclusive(from: startOfWeek, to: endOfWeek))
          .map((log) {
        final values = _calculateMetric(sets: log.sets);
        return values;
      }).sum;
      valuesForWeek.add(values);
      weeks.add(weekCounter);
      weekCounter += 1;
    }

    final nonZeroValues = valuesForWeek.where((value) => value > 0).toList();

    final avgValue = nonZeroValues.isNotEmpty ? nonZeroValues.average.round() : 0;

    final chartPoints =
        valuesForWeek.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();

    final weeksLabels = weeks.mapIndexed((index, _) {
      return "WK ${index + 1}";
    }).toList();

    final totalOptimal = _weightWhere(values: nonZeroValues, condition: (value) => value >= _optimalSetsOrRepsValue());
    final totalSufficient = _weightWhere(
        values: nonZeroValues,
        condition: (value) => value >= _sufficientSetsOrRepsValue() && value < _optimalSetsOrRepsValue());
    final totalMinimum =
        _weightWhere(values: nonZeroValues, condition: (value) => value < _sufficientSetsOrRepsValue());

    final weights = [totalOptimal, totalSufficient, totalMinimum];

    final hasWeights = weights.any((weight) => weight > 0);

    final weightColors = [vibrantGreen, vibrantBlue, Colors.deepOrangeAccent];

    final barColors = valuesForWeek
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
                  onMonthChange: _onMonthChange
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
                    items: MuscleGroup.values.map<DropdownMenuItem<MuscleGroup>>((MuscleGroup muscleGroup) {
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
                const SizedBox(height: 18),
                TRKRInformationContainer(
                  ctaLabel: "Review your ${_selectedMuscleGroup.name} training",
                  description: _selectedMuscleGroup.description,
                  onTap: () => _generateSummary(logs: exerciseLogs),
                ),
                const SizedBox(height: 20),
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
                        SetRepsVolumeReps.reps: SizedBox(
                            width: 40,
                            child: Text(SetRepsVolumeReps.reps.name, style: textStyle, textAlign: TextAlign.center)),
                        SetRepsVolumeReps.sets: SizedBox(
                            width: 40,
                            child: Text(SetRepsVolumeReps.sets.name, style: textStyle, textAlign: TextAlign.center)),
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
                      periods: weeksLabels,
                      barColors: _metric != SetRepsVolumeReps.volume ? barColors : null,
                      unit: _chartUnit(),
                      bottomTitlesInterval: 1,
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
      final startDate = logs.first.createdAt;
      final endDate = logs.last.createdAt;

      final userInstructions =
          "Review my workout logs for ${_selectedMuscleGroup.name} from $startDate to $endDate and provide feedback";

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
        _logs = dtos.where((log) => log.createdAt.isSameMonthYear(range.start)).toList();
      });
    });

    _hideLoadingScreen();
  }

  void _onMonthChange(DateTimeRange range) {
    setState(() {
      _dateTime = range.start;
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
  }
}

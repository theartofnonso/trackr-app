import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/health_and_fitness_stats.dart';
import 'package:tracker_app/openAI/open_ai_functions.dart';
import 'package:tracker_app/screens/AI/routine_logs_report_screen.dart';
import 'package:tracker_app/utils/date_utils.dart';
import 'package:tracker_app/utils/dialog_utils.dart';
import 'package:tracker_app/utils/general_utils.dart';
import 'package:tracker_app/utils/string_utils.dart';
import 'package:tracker_app/widgets/ai_widgets/trkr_coach_widget.dart';
import 'package:tracker_app/widgets/empty_states/horizontal_stacked_bars_empty_state.dart';

import '../../colors.dart';
import '../../controllers/exercise_and_routine_controller.dart';
import '../../dtos/graph/chart_point_dto.dart';
import '../../dtos/open_ai_response_schema_dtos/routine_logs_report_dto.dart';
import '../../dtos/set_dtos/reps_dto.dart';
import '../../dtos/set_dtos/set_dto.dart';
import '../../dtos/set_dtos/weight_and_reps_dto.dart';
import '../../enums/chart_unit_enum.dart';
import '../../enums/exercise_type_enums.dart';
import '../../enums/muscle_group_enums.dart';
import '../../enums/sets_reps_volume_enum.dart';
import '../../openAI/open_ai.dart';
import '../../strings/ai_prompts.dart';
import '../../utils/exercise_logs_utils.dart';
import '../../utils/navigation_utils.dart';
import '../../widgets/ai_widgets/trkr_information_container.dart';
import '../../widgets/backgrounds/trkr_loading_screen.dart';
import '../../widgets/buttons/opacity_button_widget.dart';
import '../../widgets/chart/bar_chart.dart';
import '../../widgets/chart/horizontal_stacked_bars.dart';
import '../../widgets/chart/legend.dart';

class SetsAndRepsVolumeInsightsScreen extends StatefulWidget {
  static const routeName = '/sets_and_reps_volume_insights_screen';

  final bool canPop;

  const SetsAndRepsVolumeInsightsScreen({super.key, this.canPop = true});

  @override
  State<SetsAndRepsVolumeInsightsScreen> createState() => _SetsAndRepsVolumeInsightsScreenState();
}

class _SetsAndRepsVolumeInsightsScreenState extends State<SetsAndRepsVolumeInsightsScreen> {
  SetRepsVolumeReps _metric = SetRepsVolumeReps.reps;

  MuscleGroup _selectedMuscleGroup = MuscleGroup.abs;

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    if (_loading) return TRKRLoadingScreen(action: _hideLoadingScreen);

    final textStyle = GoogleFonts.ubuntu(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white70);

    final dateRange = theLastYearDateTimeRange();

    final routineLogController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    final logs = routineLogController.whereLogsIsWithinRange(range: dateRange);

    final exerciseLogs = logs
        .map((log) => completedExercises(exerciseLogs: log.exerciseLogs))
        .expand((exerciseLogs) => exerciseLogs)
        .where((exerciseLog) {
      final muscleGroups = [exerciseLog.exercise.primaryMuscleGroup, ...exerciseLog.exercise.secondaryMuscleGroups];
      return muscleGroups.contains(_selectedMuscleGroup);
    }).toList();

    print(exerciseLogs.length);

    final weeksInYear = generateWeeksInRange(range: dateRange);
    List<num> trends = [];
    List<String> weeks = [];
    List<String> months = [];
    int weekCounter = 0;
    for (final week in weeksInYear) {
      final startOfWeek = week.start;
      final endOfWeek = week.end;
      final values = exerciseLogs
          .where((exerciseLog) => exerciseLog.createdAt.isBetweenInclusive(from: startOfWeek, to: endOfWeek))
          .map((log) {
        final values = _calculateMetric(sets: log.sets);
        return values;
      }).sum;
      trends.add(values);
      weeks.add("WK ${weekCounter + 1}");
      months.add(startOfWeek.formattedMonth());
      weekCounter += 1;
    }

    final nonZeroValues = trends.where((value) => value > 0).toList();

    final avgValue = nonZeroValues.isNotEmpty ? nonZeroValues.average.round() : 0;

    final chartPoints = trends.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();

    final totalOptimal = _weightWhere(values: nonZeroValues, condition: (value) => value >= _optimalSetsOrRepsValue());
    final totalSufficient = _weightWhere(
        values: nonZeroValues,
        condition: (value) => value >= _sufficientSetsOrRepsValue() && value < _optimalSetsOrRepsValue());
    final totalMinimum =
        _weightWhere(values: nonZeroValues, condition: (value) => value < _sufficientSetsOrRepsValue());

    final weights = [totalOptimal, totalSufficient, totalMinimum];

    final hasWeights = weights.any((weight) => weight > 0);

    final weightColors = [vibrantGreen, vibrantBlue, Colors.deepOrangeAccent];

    final barColors = trends
        .map((value) => _metric == SetRepsVolumeReps.sets
            ? setsTrendColor(sets: value.toInt())
            : repsTrendColor(reps: value.toInt()))
        .toList();

    final muscleGroups = MuscleGroup.values
        .sorted((a, b) => a.name.compareTo(b.name))
        .map((muscleGroup) => Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: OpacityButtonWidget(
                  onPressed: () => _onSelectMuscleGroup(newMuscleGroup: muscleGroup),
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  textStyle: GoogleFonts.ubuntu(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: muscleGroup == _selectedMuscleGroup ? vibrantGreen : Colors.white70),
                  buttonColor: muscleGroup == _selectedMuscleGroup ? vibrantGreen : null,
                  label: muscleGroup.name.toUpperCase()),
            ))
        .toList();

    final muscleGroupScrollViewHalf = MuscleGroup.values.length ~/ 2;

    return Scaffold(
      appBar: widget.canPop
          ? AppBar(
              backgroundColor: sapphireDark80,
              leading: IconButton(
                icon: const FaIcon(FontAwesomeIcons.squareXmark, color: Colors.white, size: 28),
                onPressed: context.pop,
              ),
              title: Text("Muscle Trend".toUpperCase(),
                  style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            )
          : null,
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
          minimum: const EdgeInsets.only(top: 10, right: 10, bottom: 20, left: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: muscleGroups.sublist(0, muscleGroupScrollViewHalf))),
                SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: muscleGroups.sublist(muscleGroupScrollViewHalf))),
                const SizedBox(height: 18),
                TRKRInformationContainer(
                  ctaLabel: "Review your ${_selectedMuscleGroup.name} training",
                  description: _selectedMuscleGroup.description,
                  onTap: () => _generateReport(exerciseLogs: exerciseLogs),
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
                      periods: months,
                      barColors: _metric != SetRepsVolumeReps.volume ? barColors : null,
                      unit: _chartUnit(),
                      bottomTitlesInterval: 5,
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

  void _onSelectMuscleGroup({required MuscleGroup newMuscleGroup}) {
    setState(() {
      _selectedMuscleGroup = newMuscleGroup;
    });
  }

  void _generateReport({required List<ExerciseLogDto> exerciseLogs}) {
    if (exerciseLogs.isEmpty) {
      showSnackbar(
          context: context, icon: const FaIcon(FontAwesomeIcons.circleInfo), message: "You don't have any logs");
    } else {
      final startDate = exerciseLogs.first.createdAt.withoutTime();
      final endDate = exerciseLogs.last.createdAt.withoutTime();

      final userInstructions =
          "Review my workout logs for ${_selectedMuscleGroup.name} from $startDate to $endDate and provide feedback. Please note, that my weights are in ${weightLabel()}";

      final StringBuffer buffer = StringBuffer();

      buffer.writeln(userInstructions);

      buffer.writeln();

      for (final exerciseLog in exerciseLogs) {
        final setSummaries = exerciseLog.sets.mapIndexed((index, set) {
          return switch (exerciseLog.exercise.type) {
            ExerciseType.weights => "Set ${index + 1}: ${exerciseLog.sets[index].summary()}",
            ExerciseType.bodyWeight => "Set ${index + 1}: ${exerciseLog.sets[index].summary()}",
            ExerciseType.duration => "Set ${index + 1}: ${exerciseLog.sets[index].summary()}",
          };
        }).toList();

        buffer.writeln("Exercise: ${exerciseLog.exercise.name}");
        buffer.writeln("Date: ${exerciseLog.createdAt.withoutTime().formattedDayAndMonthAndYear()}");
        buffer.writeln("Sets: $setSummaries");

        buffer.writeln();
      }

      final completeInstructions = buffer.toString();

      _showLoadingScreen();

      runMessage(
              system: routineLogSystemInstruction,
              user: completeInstructions,
              responseFormat: routineLogsReportResponseFormat)
          .then((response) {
        _hideLoadingScreen();
        if (mounted) {
          if (response != null) {
            // Deserialize the JSON string
            Map<String, dynamic> json = jsonDecode(response);

            // Create an instance of ExerciseLogsResponse
            RoutineLogsReportDto report = RoutineLogsReportDto.fromJson(json);
            navigateWithSlideTransition(
                context: context,
                child: RoutineLogsReportScreen(
                    muscleGroup: _selectedMuscleGroup, report: report, exerciseLogs: exerciseLogs));
          }
        }
      }).catchError((_) {
        _hideLoadingScreen();
        if (mounted) {
          showSnackbar(
              context: context,
              icon: TRKRCoachWidget(),
              message: "Oops! I am unable to generate your ${_selectedMuscleGroup.name} report");
        }
      });
    }
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
      SetRepsVolumeReps.reps => sets.map((set) {
          if (set is RepsSetDto) {
            return set.reps;
          } else if (set is WeightAndRepsSetDto) {
            return set.reps;
          }
          return 0;
        }).sum,
      SetRepsVolumeReps.volume => sets.map((set) => (set as WeightAndRepsSetDto).volume()).sum,
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
    return _metric == SetRepsVolumeReps.sets ? averageMedianWeeklySets : averageMedianWeeklyReps;
  }

  int _optimalSetsOrRepsValue() {
    return _metric == SetRepsVolumeReps.sets ? averageMaximumWeeklySets : averageMaximumWeeklyReps;
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
    final defaultMuscleGroup = Provider.of<ExerciseAndRoutineController>(context, listen: false)
        .logs
        .firstOrNull
        ?.exerciseLogs
        .firstOrNull
        ?.exercise
        .primaryMuscleGroup;
    _selectedMuscleGroup = defaultMuscleGroup ?? MuscleGroup.values.first;
  }
}

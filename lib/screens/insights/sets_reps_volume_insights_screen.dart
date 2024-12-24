import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/health_and_fitness_stats.dart';
import 'package:tracker_app/openAI/open_ai_response_format.dart';
import 'package:tracker_app/screens/AI/muscle_group_training_report_screen.dart';
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
import '../../enums/muscle_group_enums.dart';
import '../../enums/posthog_analytics_event.dart';
import '../../enums/sets_reps_volume_enum.dart';
import '../../openAI/open_ai.dart';
import '../../strings/ai_prompts.dart';
import '../../utils/exercise_logs_utils.dart';
import '../../utils/navigation_utils.dart';
import '../../utils/one_rep_max_calculator.dart';
import '../../utils/sets_utils.dart';
import '../../widgets/ai_widgets/trkr_information_container.dart';
import '../../widgets/backgrounds/trkr_loading_screen.dart';
import '../../widgets/buttons/opacity_button_widget.dart';
import '../../widgets/chart/bar_chart.dart';
import '../../widgets/chart/horizontal_stacked_bars.dart';
import '../../widgets/chart/legend.dart';

class TrendAndDate {
  final num value;
  final DateTime dateTime;

  TrendAndDate({required this.value, required this.dateTime});
}

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
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    if (_loading) return TRKRLoadingScreen(action: _hideLoadingScreen);

    final textStyle = Theme.of(context).textTheme.bodySmall;

    final dateRange = theLastYearDateTimeRange();

    final routineLogController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    final logs = routineLogController.whereLogsIsWithinRange(range: dateRange);

    final exerciseLogs = logs
        .map((log) => loggedExercises(exerciseLogs: log.exerciseLogs))
        .expand((exerciseLogs) => exerciseLogs)
        .where((exerciseLog) {
      final muscleGroups = [exerciseLog.exercise.primaryMuscleGroup, ...exerciseLog.exercise.secondaryMuscleGroups];
      return muscleGroups.contains(_selectedMuscleGroup);
    }).toList();

    final weeksInYear = generateWeeksInRange(range: dateRange);
    List<num> trends = [];
    List<String> weeks = [];
    List<String> months = [];
    List<TrendAndDate> trendAndDates = [];
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
      trendAndDates.add(TrendAndDate(value: values, dateTime: startOfWeek));
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
        .map((value) => switch (_metric) {
              SetRepsVolumeReps.sets => setsTrendColor(sets: value.toInt()),
              SetRepsVolumeReps.reps => repsTrendColor(reps: value.toInt()),
              SetRepsVolumeReps.volume => isDarkMode ? Colors.white : Colors.grey.shade400,
            })
        .toList();

    final muscleGroups = MuscleGroup.values
        .sorted((a, b) => a.name.compareTo(b.name))
        .map((muscleGroup) => Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: OpacityButtonWidget(
                  onPressed: () => _onSelectMuscleGroup(newMuscleGroup: muscleGroup),
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  buttonColor: muscleGroup == _selectedMuscleGroup ? vibrantGreen : null,
                  label: muscleGroup.name.toUpperCase()),
            ))
        .toList();

    final muscleGroupScrollViewHalf = MuscleGroup.values.length ~/ 2;

    final currentAndPreviousWeekTrend = _calculateCurrentAndPreviousValues(trends: trendAndDates);

    final previousWeekTrend = currentAndPreviousWeekTrend.$1;
    final currentMonthTrend = currentAndPreviousWeekTrend.$2;

    final improved = currentMonthTrend > previousWeekTrend;

    final difference = improved ? currentMonthTrend - previousWeekTrend : previousWeekTrend - currentMonthTrend;

    final differenceSummary = _generateDifferenceSummary(difference: difference, improved: improved);

    return Scaffold(
      appBar: widget.canPop
          ? AppBar(
              leading: IconButton(
                icon: const FaIcon(FontAwesomeIcons.squareXmark, size: 28),
                onPressed: context.pop,
              ),
              title: Text("Muscle Trend".toUpperCase()),
            )
          : null,
      body: Container(
        decoration: BoxDecoration(
          gradient: themeGradient(context: context),
        ),
        child: SafeArea(
          minimum: const EdgeInsets.only(top: 10, bottom: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      const SizedBox(width: 10),
                      ...muscleGroups.sublist(0, muscleGroupScrollViewHalf),
                      const SizedBox(width: 10)
                    ])),
                SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      const SizedBox(width: 10),
                      ...muscleGroups.sublist(muscleGroupScrollViewHalf),
                      const SizedBox(width: 10)
                    ])),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                                style: Theme.of(context).textTheme.headlineMedium,
                                children: [
                                  TextSpan(
                                    text: " ",
                                  ),
                                  TextSpan(
                                      text: _metricLabel().toUpperCase(),
                                      style: Theme.of(context).textTheme.bodyMedium),
                                ],
                              ),
                            ),
                            Text(
                              "WEEKLY AVERAGE",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                FaIcon(
                                  improved ? FontAwesomeIcons.arrowUp : FontAwesomeIcons.arrowDown,
                                  color: improved ? vibrantGreen : Colors.deepOrange,
                                  size: 12,
                                ),
                                const SizedBox(width: 6),
                                OpacityButtonWidget(
                                  label: differenceSummary,
                                  buttonColor: improved ? vibrantGreen : Colors.deepOrange,
                                )
                              ],
                            )
                          ],
                        ),
                        CupertinoSlidingSegmentedControl<SetRepsVolumeReps>(
                          backgroundColor: isDarkMode ? sapphireDark : Colors.grey.shade200,
                          thumbColor: isDarkMode ? sapphireDark80 : Colors.white,
                          groupValue: _metric,
                          children: {
                            SetRepsVolumeReps.reps: SizedBox(
                                width: 40,
                                child:
                                    Text(SetRepsVolumeReps.reps.name, style: textStyle, textAlign: TextAlign.center)),
                            SetRepsVolumeReps.sets: SizedBox(
                                width: 40,
                                child:
                                    Text(SetRepsVolumeReps.sets.name, style: textStyle, textAlign: TextAlign.center)),
                            SetRepsVolumeReps.volume: SizedBox(
                                width: 40,
                                child:
                                    Text(SetRepsVolumeReps.volume.name, style: textStyle, textAlign: TextAlign.center)),
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
                          barColors: barColors,
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
                          style: Theme.of(context).textTheme.titleMedium,
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
                  ]),
                )
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
    final exerciseLogsWithPrimaryMuscleGroups =
        exerciseLogs.where((exerciseLog) => exerciseLog.exercise.primaryMuscleGroup == _selectedMuscleGroup).toList();

    if (exerciseLogsWithPrimaryMuscleGroups.isEmpty) {
      showSnackbar(
          context: context, icon: const FaIcon(FontAwesomeIcons.circleInfo), message: "You don't have any logs");

      return;
    }

    final StringBuffer buffer = StringBuffer();

    buffer.writeln(
        "Please analyze my performance for ${_selectedMuscleGroup.name} training by comparing the sets in each exercise.");

    buffer.writeln();

    for (final exerciseLog in exerciseLogsWithPrimaryMuscleGroups) {
      buffer.writeln("Rep Range for ${exerciseLog.exercise.name}: ${exerciseLog.minReps} to ${exerciseLog.maxReps}");

      List<String> setSummaries = generateSetSummaries(exerciseLog);
      buffer.writeln(
          "Sets logged for ${exerciseLog.exercise.name} on ${exerciseLog.createdAt.withoutTime().formattedDayAndMonthAndYear()}: $setSummaries");

      final completedPastExerciseLogs = loggedExercises(exerciseLogs: exerciseLogsWithPrimaryMuscleGroups);
      final previousLog = completedPastExerciseLogs.last;
      final heaviestSetWeight = heaviestWeightInSetForExerciseLog(exerciseLog: previousLog);
      final oneRepMax = average1RM(weight: (heaviestSetWeight).weight, reps: (heaviestSetWeight).reps);

      buffer.writeln("One Rep Max for ${exerciseLog.exercise.name}: $oneRepMax");

      buffer.writeln();
    }

    buffer.writeln();

    buffer.writeln("""
    
           Below is information about different rep ranges and their corresponding training goals and recommended intensity levels:
	            •	1–5 reps: Strength & Power, Heavy (80–90% of 1RM)
	            •	6–12 reps: Hypertrophy (Muscle Growth), Moderate-Heavy (65–80% of 1RM)
	            •	12–20+ reps: Muscular Endurance, Light-Moderate (50–65% of 1RM)
	              
          Please provide feedback on the following aspects of my ${_selectedMuscleGroup.name} training performance:
              1.	Weights Lifted: Analyze the progression or consistency in the weights I’ve used.
      	      2.	Repetitions: Evaluate the number of repetitions performed per set and identify any trends or changes.
      	      3.	Volume Lifted: Calculate the total volume lifted (weight × repetitions) and provide insights into its progression over time.
      	      4.	Number of Sets: Assess the number of sets performed and how it aligns with my overall workout goals.
              5.  Using the above guidelines on reps ranges, training goals, intensity levels and my one Rep Max, analyze my training intensity (weight and reps) and provide clear, actionable recommendations on whether the I should increase or decrease the weights.
           
          Note: All weights are measured in ${weightLabel()}.
          Note: Your report should sound personal.
          """);

    final completeInstructions = buffer.toString();

    _showLoadingScreen();

    runMessage(
            system: routineLogSystemInstruction,
            user: completeInstructions,
            responseFormat: routineLogsReportResponseFormat)
        .then((response) {
      if (kReleaseMode) {
        Posthog().capture(eventName: PostHogAnalyticsEvent.generateMuscleGroupTrainingReport.displayName);
      }
      _hideLoadingScreen();
      if (mounted) {
        if (response != null) {
          // Deserialize the JSON string
          Map<String, dynamic> json = jsonDecode(response);

          // Create an instance of ExerciseLogsResponse
          RoutineLogsReportDto report = RoutineLogsReportDto.fromJson(json);
          navigateWithSlideTransition(
              context: context,
              child: MuscleGroupTrainingReportScreen(
                  muscleGroup: _selectedMuscleGroup,
                  report: report,
                  exerciseLogs: exerciseLogsWithPrimaryMuscleGroups));
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
      SetRepsVolumeReps.volume => sets.map((set) {
          if (set is WeightAndRepsSetDto) {
            return set.volume();
          }
          return 0;
        }).sum,
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

  (num, num) _calculateCurrentAndPreviousValues({required List<TrendAndDate> trends}) {
    if (trends.isEmpty) {
      // No values => no comparison
      return (0, 0);
    }

    // 2. Identify the most recent value
    final lastValue = trends.last;
    final lastValueDate = trends.last.dateTime;

    final previousValues = trends.where((trend) => trend.dateTime.isBefore(lastValueDate));

    if (previousValues.isEmpty) {
      // No earlier values => can't compare
      return (0, 0);
    }

    final previousValue = previousValues.last.value;

    return (previousValue, lastValue.value);
  }

  String _generateDifferenceSummary({required bool improved, required num difference}) {
    if (difference <= 0) {
      return "0 change in past week";
    } else {
      if (improved) {
        return switch (_metric) {
          SetRepsVolumeReps.sets => "$difference sets up this week",
          SetRepsVolumeReps.reps => "$difference reps up this week",
          SetRepsVolumeReps.volume => "${volumeInKOrM(difference.toDouble())} ${weightLabel()} up this week"
        };
      } else {
        return switch (_metric) {
          SetRepsVolumeReps.sets => "$difference sets down this week",
          SetRepsVolumeReps.reps => "$difference reps down this week",
          SetRepsVolumeReps.volume => "${volumeInKOrM(difference.toDouble())} ${weightLabel()} down this week"
        };
      }
    }
  }
}

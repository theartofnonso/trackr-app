import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/extensions/muscle_group_extension.dart';
import 'package:tracker_app/health_and_fitness_stats.dart';
import 'package:tracker_app/openAI/open_ai_response_format.dart';
import 'package:tracker_app/screens/AI/muscle_group_training_report_screen.dart';
import 'package:tracker_app/screens/insights/knowledge_articles/kb_reps_screen.dart';
import 'package:tracker_app/utils/date_utils.dart';
import 'package:tracker_app/utils/dialog_utils.dart';
import 'package:tracker_app/utils/general_utils.dart';
import 'package:tracker_app/utils/string_utils.dart';
import 'package:tracker_app/widgets/ai_widgets/trkr_coach_widget.dart';
import 'package:tracker_app/widgets/empty_states/horizontal_stacked_bars_empty_state.dart';

import '../../colors.dart';
import '../../controllers/exercise_and_routine_controller.dart';
import '../../dtos/graph/chart_point_dto.dart';
import '../../dtos/open_ai_response_schema_dtos/exercise_performance_report.dart';
import '../../dtos/set_dtos/reps_dto.dart';
import '../../dtos/set_dtos/set_dto.dart';
import '../../dtos/set_dtos/weight_and_reps_dto.dart';
import '../../enums/chart_unit_enum.dart';
import '../../enums/muscle_group_enums.dart';
import '../../enums/posthog_analytics_event.dart';
import '../../enums/training_metric_enum.dart';
import '../../openAI/open_ai.dart';
import '../../strings/ai_prompts.dart';
import '../../utils/data_trend_utils.dart';
import '../../utils/exercise_logs_utils.dart';
import '../../utils/navigation_utils.dart';
import '../../utils/one_rep_max_calculator.dart';
import '../../utils/routine_log_utils.dart';
import '../../utils/sets_utils.dart';
import '../../widgets/ai_widgets/trkr_information_container.dart';
import '../../widgets/backgrounds/trkr_loading_screen.dart';
import '../../widgets/buttons/opacity_button_widget.dart';
import '../../widgets/chart/bar_chart.dart';
import '../../widgets/chart/horizontal_stacked_bars.dart';
import '../../widgets/chart/legend.dart';
import '../../widgets/dividers/label_divider.dart';
import '../../widgets/insights_grid_item_widget.dart';
import 'knowledge_articles/kb_sets_screen.dart';
import 'knowledge_articles/kb_volume_screen.dart';

class _TrendAndDate {
  final num value;
  final DateTime dateTime;

  _TrendAndDate({required this.value, required this.dateTime});
}

class SetsAndRepsVolumeInsightsScreen extends StatefulWidget {
  static const routeName = '/sets_and_reps_volume_insights_screen';

  final bool canPop;

  const SetsAndRepsVolumeInsightsScreen({super.key, this.canPop = true});

  @override
  State<SetsAndRepsVolumeInsightsScreen> createState() => _SetsAndRepsVolumeInsightsScreenState();
}

class _SetsAndRepsVolumeInsightsScreenState extends State<SetsAndRepsVolumeInsightsScreen> {
  TrainingMetric _metric = TrainingMetric.reps;

  MuscleGroup? _selectedMuscleGroup;

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    if (_loading) return TRKRLoadingScreen(action: _hideLoadingScreen);

    final textStyle = Theme.of(context).textTheme.bodySmall;

    final dateRange = theLastYearDateTimeRange();

    final exerciseAndRoutineController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    final logs = exerciseAndRoutineController.whereLogsIsWithinRange(range: dateRange);

    final exerciseLogs =
        logs.map((log) => loggedExercises(exerciseLogs: log.exerciseLogs)).expand((exerciseLogs) => exerciseLogs);

    final exerciseLogsForSelectedMuscleGroup = exerciseLogs.where((exerciseLog) {
      return _selectedMuscleGroup == exerciseLog.exercise.primaryMuscleGroup;
    }).toList();

    final weeksInYear = generateWeeksInRange(range: dateRange);

    List<num> trends = [];
    List<String> weeks = [];
    List<String> months = [];
    List<_TrendAndDate> trendAndDates = [];
    int weekCounter = 0;
    for (final week in weeksInYear) {
      final startOfWeek = week.start;
      final endOfWeek = week.end;
      final values = exerciseLogsForSelectedMuscleGroup
          .where((exerciseLog) => exerciseLog.createdAt.isBetweenInclusive(from: startOfWeek, to: endOfWeek))
          .map((log) {
        final values = _calculateMetric(sets: log.sets);
        return values;
      }).sum;
      trends.add(values);
      weeks.add("WK ${weekCounter + 1}");
      months.add(startOfWeek.formattedMonth());
      trendAndDates.add(_TrendAndDate(value: values, dateTime: startOfWeek));
      weekCounter += 1;
    }

    final nonZeroValues = trends.where((value) => value > 0).toList();

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
              TrainingMetric.sets => setsTrendColor(sets: value.toInt()),
              TrainingMetric.reps => repsTrendColor(reps: value.toInt()),
              TrainingMetric.volume => isDarkMode ? Colors.white : Colors.grey.shade400,
            })
        .toList();

    final muscleGroups = exerciseLogs
        .map((exerciseLog) => exerciseLog.exercise.primaryMuscleGroup)
        .toSet()
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

    final trendSummary = _analyzeWeeklyTrends(values: trends);

    final leanMoreChildren = [
      InsightsGridItemWidget(
        title: 'Reps and Ranges: Mastering the Basics for Optimal Training',
        onTap: () => navigateWithSlideTransition(context: context, child: KbRepsScreen()),
        image: 'images/man_dumbbell.jpg',
      ),
      InsightsGridItemWidget(
        title: 'Sets: A Deep Dive into Strength Training Fundamentals',
        onTap: () => navigateWithSlideTransition(context: context, child: KbSetsScreen()),
        image: 'images/girl_standing_man_squatting.jpg',
      ),
      InsightsGridItemWidget(
        title: 'Volume vs. Intensity: Unlocking the Key to Effective Training',
        onTap: () => navigateWithSlideTransition(context: context, child: KbVolumeScreen()),
        image: 'images/orange_dumbbells.jpg',
      )
    ];

    final selectedMuscleGroup = _selectedMuscleGroup;

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
          minimum: const EdgeInsets.only(top: 10),
          bottom: false,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    scrollDirection: Axis.horizontal,
                    child: Row(mainAxisAlignment: MainAxisAlignment.start, children: muscleGroups)),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(spacing: 20, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if (selectedMuscleGroup != null)
                      TRKRInformationContainer(
                        color: isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
                        ctaLabel: "Review your ${selectedMuscleGroup.name} training",
                        description: selectedMuscleGroup.description,
                        onTap: () => _generateReport(exerciseLogs: exerciseLogsForSelectedMuscleGroup),
                        icon: Image.asset(
                          'muscles_illustration/${_selectedMuscleGroup?.illustration()}.png',
                          fit: BoxFit.contain,
                          height: 30, // Adjust the height as needed
                        ),
                      ),
                    Column(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 10,
                          children: [
                            trendSummary.trend == Trend.none
                                ? const SizedBox.shrink()
                                : getTrendIcon(trend: trendSummary.trend),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    text:
                                        "${_metric == TrainingMetric.volume ? volumeInKOrM(trendSummary.average, showLessThan1k: false) : trendSummary.average}",
                                    style: Theme.of(context).textTheme.headlineSmall,
                                    children: [
                                      TextSpan(
                                        text: " ",
                                      ),
                                      TextSpan(
                                        text: _metricLabel().toUpperCase(),
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  "Weekly AVERAGE".toUpperCase(),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            )
                          ],
                        ),
                        Text(trendSummary.summary,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w400, color: isDarkMode ? Colors.white70 : Colors.black)),
                        CupertinoSlidingSegmentedControl<TrainingMetric>(
                          backgroundColor: isDarkMode ? sapphireDark : Colors.grey.shade200,
                          thumbColor: isDarkMode ? sapphireDark80 : Colors.white,
                          groupValue: _metric,
                          children: {
                            TrainingMetric.reps: SizedBox(
                                width: 40,
                                child: Text(TrainingMetric.reps.name, style: textStyle, textAlign: TextAlign.center)),
                            TrainingMetric.sets: SizedBox(
                                width: 40,
                                child: Text(TrainingMetric.sets.name, style: textStyle, textAlign: TextAlign.center)),
                            TrainingMetric.volume: SizedBox(
                                width: 40,
                                child: Text(TrainingMetric.volume.name, style: textStyle, textAlign: TextAlign.center)),
                          },
                          onValueChanged: (TrainingMetric? value) {
                            if (value != null) {
                              setState(() {
                                _metric = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
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
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: LabelDivider(
                    label: "Learn about training basics".toUpperCase(),
                    labelColor: isDarkMode ? Colors.white70 : Colors.black,
                    dividerColor: sapphireLighter,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: GridView.count(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      scrollDirection: Axis.horizontal,
                      crossAxisCount: 1,
                      childAspectRatio: 1.2,
                      mainAxisSpacing: 10.0,
                      children: leanMoreChildren),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    final dateRange = theLastYearDateTimeRange();

    final exerciseAndRoutineController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    final logs = exerciseAndRoutineController.whereLogsIsWithinRange(range: dateRange);

    final exerciseLogs =
        logs.map((log) => loggedExercises(exerciseLogs: log.exerciseLogs)).expand((exerciseLogs) => exerciseLogs);

    _selectedMuscleGroup = exerciseLogs.firstOrNull?.exercise.primaryMuscleGroup;
  }

  void _showLoadingScreen() {
    setState(() {
      _loading = true;
    });
  }

  void _hideLoadingScreen() {
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  void _onSelectMuscleGroup({required MuscleGroup newMuscleGroup}) {
    setState(() {
      _selectedMuscleGroup = newMuscleGroup;
    });
  }

  void _generateReport({required List<ExerciseLogDto> exerciseLogs}) {
    final selectedMuscleGroup = _selectedMuscleGroup;

    if (selectedMuscleGroup == null) return;

    final exerciseLogsForMuscleGroups = exerciseLogs
        .where((exerciseLog) => exerciseLog.exercise.primaryMuscleGroup == selectedMuscleGroup)
        .sorted((a, b) => b.createdAt.compareTo(a.createdAt))
        .toList();

    if (exerciseLogsForMuscleGroups.isEmpty) {
      showSnackbar(
          context: context, icon: const FaIcon(FontAwesomeIcons.circleInfo), message: "You don't have any logs");

      return;
    }

    final StringBuffer buffer = StringBuffer();

    for (final exerciseLog in exerciseLogsForMuscleGroups) {
      buffer.writeln("Exercise Id for ${exerciseLog.exercise.name}: ${exerciseLog.exercise.id}");

      List<String> setSummaries = generateSetSummaries(exerciseLog);
      buffer.writeln(
          "Sets logged for ${exerciseLog.exercise.name} on ${exerciseLog.createdAt.withoutTime().formattedDayAndMonthAndYear()}: $setSummaries");

      final heaviestSetWeight = heaviestWeightInSetForExerciseLog(exerciseLog: exerciseLogs.last);
      final oneRepMax = average1RM(weight: (heaviestSetWeight).weight, reps: (heaviestSetWeight).reps);

      buffer.writeln("One Rep Max for ${exerciseLog.exercise.name}: $oneRepMax");

      buffer.writeln();
    }

    buffer.writeln();

    final trainingPrompt = generateTrainingPrompt(muscleGroups: [selectedMuscleGroup]);

    buffer.writeln(trainingPrompt);

    final completeInstructions = buffer.toString();

    _showLoadingScreen();

    runMessage(
            system: routineLogSystemInstruction,
            user: completeInstructions,
            responseFormat: muscleGroupTrainingReportResponseFormat)
        .then((response) {
      Posthog().capture(eventName: PostHogAnalyticsEvent.generateMuscleGroupTrainingReport.displayName);

      _hideLoadingScreen();
      if (mounted) {
        if (response != null) {
          // Deserialize the JSON string
          Map<String, dynamic> json = jsonDecode(response);

          // Create an instance of ExerciseLogsResponse
          ExercisePerformanceReport report = ExercisePerformanceReport.fromJson(json);
          navigateWithSlideTransition(
              context: context,
              child: MuscleGroupTrainingReportScreen(
                  muscleGroup: selectedMuscleGroup, report: report, exerciseLogs: exerciseLogs));
        }
      }
    }).catchError((_) {
      _hideLoadingScreen();
      if (mounted) {
        showSnackbar(
            context: context,
            icon: TRKRCoachWidget(),
            message: "Oops! I am unable to generate your ${selectedMuscleGroup.name} report");
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
      TrainingMetric.sets => sets.length,
      TrainingMetric.reps => sets.map((set) {
          if (set is RepsSetDto) {
            return set.reps;
          } else if (set is WeightAndRepsSetDto) {
            return set.reps;
          }
          return 0;
        }).sum,
      TrainingMetric.volume => sets.map((set) {
          if (set is WeightAndRepsSetDto) {
            return set.volume();
          }
          return 0;
        }).sum,
    };
  }

  double _reservedSize() {
    return switch (_metric) {
      TrainingMetric.sets => 20,
      TrainingMetric.reps => 25,
      TrainingMetric.volume => 40,
    };
  }

  bool _isRepsOrSetsMetric() {
    return _metric == TrainingMetric.sets || _metric == TrainingMetric.reps;
  }

  int _sufficientSetsOrRepsValue() {
    return _metric == TrainingMetric.sets ? averageMedianWeeklySets : averageMedianWeeklyReps;
  }

  int _optimalSetsOrRepsValue() {
    return _metric == TrainingMetric.sets ? averageMaximumWeeklySets : averageMaximumWeeklyReps;
  }

  ChartUnit _chartUnit() {
    return switch (_metric) {
      TrainingMetric.sets => ChartUnit.number,
      TrainingMetric.reps => ChartUnit.number,
      TrainingMetric.volume => ChartUnit.weight,
    };
  }

  String _metricLabel() {
    final unit = _chartUnit();
    return switch (unit) {
      ChartUnit.number || ChartUnit.numberBig => _metric.name,
      ChartUnit.weight => weightUnit(),
      ChartUnit.duration => "",
    };
  }

  String _trainingMetric({required int length}) {
    return switch (_metric) {
      TrainingMetric.sets => pluralize(word: "set", count: length),
      TrainingMetric.reps => pluralize(word: "rep", count: length),
      TrainingMetric.volume => weightUnit().toUpperCase()
    };
  }

  TrendSummary _analyzeWeeklyTrends({required List<num> values}) {
    final selectedMuscleGroup = _selectedMuscleGroup;

    if (selectedMuscleGroup == null) {
      return TrendSummary(
          trend: Trend.none,
          average: 0,
          summary: "🤔 No training data available yet. Log some sessions to start tracking your progress!");
    }

    // 1. Handle edge cases
    if (values.isEmpty) {
      return TrendSummary(
          trend: Trend.none,
          average: 0,
          summary: "🤔 No training data available yet. Log some sessions to start tracking your progress!");
    }

    final previousVolumes = values.sublist(0, values.length - 1);
    final averageOfPrevious = (previousVolumes.reduce((a, b) => a + b) / previousVolumes.length).round();

    if (values.length == 1) {
      return TrendSummary(
          trend: Trend.none,
          average: averageOfPrevious,
          summary: "🌟 You've logged your first week's training."
              " Great job! Keep logging more data to see trends over time.");
    }

    // 2. Identify the last week's volume and the average of all previous weeks
    final lastWeekVolume = values.last;

    if (lastWeekVolume == 0) {
      return TrendSummary(
          trend: Trend.none,
          average: averageOfPrevious,
          summary:
              "🤔 No training data available for this week. Log some workouts to continue tracking your progress!");
    }

    // 3. Compare last week's volume to the average of previous volumes
    final difference = (lastWeekVolume - averageOfPrevious).round();

    // Special check for no difference
    final differenceIsZero = difference == 0;

    // If the average is zero, treat it as a special case for percentage change
    final bool averageIsZero = averageOfPrevious == 0;
    final double percentageChange = averageIsZero ? 100.0 : (difference / averageOfPrevious) * 100;

    // 4. Decide the trend
    const threshold = 5; // Adjust this threshold for "stable" as needed
    late final Trend trend;
    if (percentageChange > threshold) {
      trend = Trend.up;
    } else if (percentageChange < -threshold) {
      trend = Trend.down;
    } else {
      trend = Trend.stable;
    }

    // 5. Generate a friendly, concise message based on the trend
    final _ = "${percentageChange.abs().toStringAsFixed(1)}%";

    final diff = _metric == TrainingMetric.volume ? volumeInKOrM(difference, showLessThan1k: false) : difference.abs();

    switch (trend) {
      case Trend.up:
        return TrendSummary(
            trend: Trend.up,
            average: averageOfPrevious,
            summary:
                "🌟🌟 This week's ${selectedMuscleGroup.name} training is $diff ${_trainingMetric(length: difference.abs())} higher than your average. "
                "Awesome job building momentum!");
      case Trend.down:
        return TrendSummary(
            trend: Trend.down,
            average: averageOfPrevious,
            summary:
                "📉 This week's ${selectedMuscleGroup.name} training is $diff ${_trainingMetric(length: difference.abs())} lower than your average. "
                "Consider extra rest, checking your technique, or planning a deload.");
      case Trend.stable:
        final summary = differenceIsZero
            ? "🌟 You've matched your average exactly! Stay consistent to see long-term progress."
            : "🔄 Your ${selectedMuscleGroup.name} training has changed by about $diff ${_trainingMetric(length: difference.abs())} compared to your average. "
                "A great chance to refine your form and maintain consistency.";
        return TrendSummary(trend: Trend.stable, average: averageOfPrevious, summary: summary);
      case Trend.none:
        return TrendSummary(trend: Trend.none, average: averageOfPrevious, summary: "🤔 Unable to identify trends");
    }
  }
}

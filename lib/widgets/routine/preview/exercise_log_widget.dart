import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/dtos/set_dtos/duration_set_dto.dart';
import 'package:tracker_app/dtos/set_dtos/reps_dto.dart';
import 'package:tracker_app/dtos/set_dtos/weight_and_reps_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/widgets/routine/preview/sets_listview.dart';

import '../../../colors.dart';
import '../../../controllers/exercise_and_routine_controller.dart';
import '../../../dtos/graph/chart_point_dto.dart';
import '../../../enums/chart_unit_enum.dart';
import '../../../screens/exercise/history/exercise_home_screen.dart';
import '../../../utils/data_trend_utils.dart';
import '../../../utils/exercise_logs_utils.dart';
import '../../../utils/general_utils.dart';
import '../../chart/line_chart_widget.dart';
import '../preview/set_headers/double_set_header.dart';
import '../preview/set_headers/single_set_header.dart';

enum StrengthStatus {
  improving(
    description: "🌟 You're getting stronger! Handling more volume with less effort shows fantastic adaptation. "
        "Keep that momentum going and consider increasing the challenge next session—just remember to watch your recovery.",
  ),
  declining(
    description: "📉 You're feeling a dip in strength. Double-check your sleep, nutrition, and stress levels—"
        "a little extra rest or a small load reduction can help you bounce back stronger!",
  ),
  maintaining(
    description: "🔄 Solid consistency! You've maintained performance levels well. "
        "Focus on refining technique and mind-muscle connection to build a perfect foundation for future gains.",
  ),
  potentialOvertraining(
    description: "⚠️ Easy there—your body might be on the verge of overtraining. "
        "Consider a short deload or reduce your training volume for a week to fully recover, then ramp back up gradually.",
  ),
  none(
    description: "🤔 We don't have enough data yet to analyze your progress. "
        "Keep logging sessions, and we'll give you tailored feedback as you go!",
  ),
  insufficient(
      description: "You’ve logged only one training. Great job! Log more sessions to identify trends over time.");

  const StrengthStatus({required this.description});

  final String description;
}

enum WeightAndRPE {
  weight(
      name: "Weight",
      description:
          "Track your heaviest weight lifted. An upward trend highlights your strength gains and consistent improvement over time."),
  rpe(
      name: "Volume and RPE",
      description:
          "Volume shows how much work you do, while RPE reveals how hard it feels. An upward volume trend shows you’re progressively handling more work. While a downward RPE trend at the same workload suggests the exercises are feeling easier.");

  const WeightAndRPE({required this.name, required this.description});

  final String name;
  final String description;
}

class ExerciseLogWidget extends StatefulWidget {
  final ExerciseLogDto exerciseLog;
  final ExerciseLogDto? superSet;

  const ExerciseLogWidget({super.key, required this.exerciseLog, this.superSet});

  @override
  State<ExerciseLogWidget> createState() => _ExerciseLogWidgetState();
}

class _ExerciseLogWidgetState extends State<ExerciseLogWidget> {
  WeightAndRPE _metric = WeightAndRPE.rpe;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall;

    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final otherSuperSet = widget.superSet;

    final exercise = widget.exerciseLog.exercise;

    final exerciseType = exercise.type;

    final routineLogController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    final pastExerciseLogs =
        routineLogController.whereExerciseLogsBefore(exercise: exercise, date: widget.exerciseLog.createdAt);

    final pbs =
        calculatePBs(pastExerciseLogs: pastExerciseLogs, exerciseType: exerciseType, exerciseLog: widget.exerciseLog);

    List<ExerciseLogDto> allExerciseLogs = routineLogController.exerciseLogsByExerciseId[exercise.id] ?? [];

    if (allExerciseLogs.length >= 5) {
      allExerciseLogs = allExerciseLogs.reversed.toList().sublist(0, 5).reversed.toList();
    } else {
      allExerciseLogs = allExerciseLogs.reversed.toList().sublist(0).reversed.toList();
    }

    final validLogs = allExerciseLogs.where((log) => log.sets.isNotEmpty).toList();

    List<ChartPointDto> chartPoints = [];

    List<ChartPointDto> volumeChartPoints = [];

    List<ChartPointDto> rpeChartPoints = [];

    List<Color> rpeColors = [];

    if (exerciseType == ExerciseType.weights && _metric == WeightAndRPE.weight) {
      final sets = validLogs.map((log) => heaviestWeightInSetForExerciseLog(exerciseLog: log)).toList();
      chartPoints = sets.mapIndexed((index, set) => ChartPointDto(index, (set).weight)).toList();
    }

    StrengthStatus strengthStatus = StrengthStatus.none;

    if (_metric == WeightAndRPE.rpe) {
      final averageRpeRatings = validLogs.map((log) {
        final rpeRatings = log.sets.map((set) => set.rpeRating);
        return rpeRatings.average.ceil();
      }).toList();

      rpeChartPoints = averageRpeRatings.mapIndexed((index, rpeRating) => ChartPointDto(index, rpeRating)).toList();
      rpeColors = averageRpeRatings.map((rpeRating) => rpeIntensityToColor[rpeRating]!).toList();

      if (exerciseType == ExerciseType.weights) {
        final totalVolumes = validLogs.map((log) {
          final volumes = log.sets.map((set) => (set as WeightAndRepsSetDto).volume());
          return volumes.sum;
        }).toList();
        volumeChartPoints = totalVolumes.mapIndexed((index, totalVolume) => ChartPointDto(index, totalVolume)).toList();
        strengthStatus =
            _analyzeVolumeRPERelationship(volumes: totalVolumes, rpes: averageRpeRatings, volume: 'Volume');
      }

      if (exerciseType == ExerciseType.bodyWeight) {
        final totalReps = validLogs.map((log) {
          final reps = log.sets.map((set) => (set as RepsSetDto).reps);
          return reps.sum;
        }).toList();
        volumeChartPoints = totalReps.mapIndexed((index, totalRep) => ChartPointDto(index, totalRep)).toList();
        strengthStatus = _analyzeVolumeRPERelationship(volumes: totalReps, rpes: averageRpeRatings, volume: 'Reps');
      }

      if (exerciseType == ExerciseType.duration) {
        final totalDuration = validLogs.map((log) {
          final durations = log.sets.map((set) => (set as DurationSetDto).duration);
          return durations.fold(Duration.zero, (sum, item) => sum + item).inMilliseconds;
        }).toList();
        volumeChartPoints =
            totalDuration.mapIndexed((index, totalDuration) => ChartPointDto(index, totalDuration)).toList();
        strengthStatus =
            _analyzeVolumeRPERelationship(volumes: totalDuration, rpes: averageRpeRatings, volume: 'Duration');
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => ExerciseHomeScreen(exercise: widget.exerciseLog.exercise)));
      },
      child: Column(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(widget.exerciseLog.exercise.name,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center),
          if (otherSuperSet != null)
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FaIcon(
                  FontAwesomeIcons.link,
                  size: 10,
                ),
                const SizedBox(width: 4),
                Text(otherSuperSet.exercise.name, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          if (widget.exerciseLog.notes.isNotEmpty)
            Text(widget.exerciseLog.notes, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
          // if (chartPoints.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDarkMode ? Colors.white10 : Colors.black38, // Border color
                width: 1.0, // Border width
              ),
              borderRadius: BorderRadius.circular(5), // Optional: Rounded corners
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 12,
              children: [
                const SizedBox(height: 2),
                _metric == WeightAndRPE.weight
                    ? Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: LineChartWidget(
                            chartPoints: chartPoints, periods: [], unit: ChartUnit.weight, aspectRation: 2.5),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Stack(children: [
                          LineChartWidget(
                              chartPoints: volumeChartPoints,
                              periods: [],
                              unit: _getChartUnit(),
                              aspectRation: 2.5,
                              rightReservedSize: 16,
                              hasRightAxisTitles: true),
                          LineChartWidget(
                              chartPoints: rpeChartPoints,
                              periods: [],
                              unit: ChartUnit.number,
                              aspectRation: 2.5,
                              colors: rpeColors,
                              lineChartSide: LineChartSide.right,
                              rightReservedSize: 16,
                              hasRightAxisTitles: true)
                        ]),
                      ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  child: Text(_metric == WeightAndRPE.weight ? _metric.description : strengthStatus.description,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          height: 1.8,
                          color: isDarkMode ? Colors.white70 : Colors.black)),
                ),
                CupertinoSlidingSegmentedControl<WeightAndRPE>(
                  backgroundColor: isDarkMode ? sapphireDark : Colors.grey.shade200,
                  thumbColor: isDarkMode ? sapphireDark80 : Colors.white,
                  groupValue: _metric,
                  children: {
                    WeightAndRPE.rpe: SizedBox(
                        width: 100, child: Text(_volumeRepsDuration(), style: textStyle, textAlign: TextAlign.center)),
                    WeightAndRPE.weight: SizedBox(
                        width: 50,
                        child: Text(WeightAndRPE.weight.name, style: textStyle, textAlign: TextAlign.center)),
                  },
                  onValueChanged: (WeightAndRPE? value) {
                    if (value != null) {
                      setState(() {
                        _metric = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          switch (exerciseType) {
            ExerciseType.weights => DoubleSetHeader(firstLabel: weightUnit().toUpperCase(), secondLabel: 'REPS'),
            ExerciseType.bodyWeight => SingleSetHeader(label: 'REPS'),
            ExerciseType.duration => SingleSetHeader(label: 'TIME'),
          },
          SetsListview(type: exerciseType, sets: widget.exerciseLog.sets, pbs: pbs)
        ],
      ),
    );
  }

  ChartUnit _getChartUnit() {
    final exerciseType = widget.exerciseLog.exercise.type;
    return switch (exerciseType) {
      ExerciseType.weights => ChartUnit.weight,
      ExerciseType.bodyWeight => ChartUnit.number,
      ExerciseType.duration => ChartUnit.duration,
    };
  }

  String _volumeRepsDuration() {
    final exerciseType = widget.exerciseLog.exercise.type;
    return switch (exerciseType) {
      ExerciseType.weights => "Volume and RPE",
      ExerciseType.bodyWeight => "Reps and RPE",
      ExerciseType.duration => "Time and RPE",
    };
  }

  StrengthStatus _analyzeVolumeRPERelationship(
      {required List<num> volumes, required List<int> rpes, required String volume}) {
    if (volumes.isEmpty || rpes.isEmpty || volumes.length != rpes.length) {
      return StrengthStatus.none;
    }

    if (volumes.length == 1) {
      return StrengthStatus.insufficient;
    }

    final volumeTrend = detectTrend(volumes);
    final rpeTrend = detectTrend(rpes); // example threshold

    if (volumeTrend == Trend.up) {
      if (rpeTrend == Trend.down || rpeTrend == Trend.stable) {
        return StrengthStatus.improving;
      } else if (rpeTrend == Trend.up) {
        return StrengthStatus.potentialOvertraining;
      }
    }

    if (volumeTrend == Trend.stable) {
      if (rpeTrend == Trend.down) {
        return StrengthStatus.improving;
      } else if (rpeTrend == Trend.stable) {
        return StrengthStatus.maintaining;
      } else if (rpeTrend == Trend.up) {
        return StrengthStatus.declining;
      }
    }

    if (volumeTrend == Trend.down) {
      if (rpeTrend == Trend.up) {
        return StrengthStatus.potentialOvertraining;
      } else if (rpeTrend == Trend.stable) {
        return StrengthStatus.maintaining;
      } else if (rpeTrend == Trend.down) {
        return StrengthStatus.declining;
      }
    }

    return StrengthStatus.maintaining;
  }
}

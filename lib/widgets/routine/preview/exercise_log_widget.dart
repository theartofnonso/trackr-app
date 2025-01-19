import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/dtos/set_dtos/weight_and_reps_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/widgets/routine/preview/sets_listview.dart';

import '../../../colors.dart';
import '../../../controllers/exercise_and_routine_controller.dart';
import '../../../dtos/graph/chart_point_dto.dart';
import '../../../enums/chart_unit_enum.dart';
import '../../../screens/exercise/history/exercise_home_screen.dart';
import '../../../utils/exercise_logs_utils.dart';
import '../../../utils/general_utils.dart';
import '../../chart/line_chart_widget.dart';
import '../preview/set_headers/double_set_header.dart';
import '../preview/set_headers/single_set_header.dart';

enum WeightVolumeRPE {
  weight(
      name: "Weight",
      description:
          "Track your heaviest weight lifted. An upward trend highlights your strength gains and consistent improvement over time."),
  volumeRPE(
      name: "Volume and RPE",
      description:
          "Volume shows how much work you do, while RPE reveals how hard it feels. An upward volume trend shows you’re progressively handling more work. While a downward RPE trend at the same workload suggests the exercises are feeling easier");

  const WeightVolumeRPE({required this.name, required this.description});

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
  WeightVolumeRPE _metric = WeightVolumeRPE.weight;

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

    if (allExerciseLogs.length >= 10) {
      allExerciseLogs = allExerciseLogs.reversed.toList().sublist(0, 10).reversed.toList();
    } else {
      allExerciseLogs = allExerciseLogs.reversed.toList().sublist(0).reversed.toList();
    }

    List<ChartPointDto> chartPoints = [];

    List<ChartPointDto> volumeChartPoints = [];

    List<ChartPointDto> rpeChartPoints = [];

    List<Color> rpeColors = [];

    if (exerciseType == ExerciseType.weights && _metric == WeightVolumeRPE.weight) {
      final sets = allExerciseLogs.map((log) => heaviestWeightInSetForExerciseLog(exerciseLog: log)).toList();
      chartPoints = sets.mapIndexed((index, set) => ChartPointDto(index, (set).weight)).toList();
    }

    if (exerciseType == ExerciseType.weights && _metric == WeightVolumeRPE.volumeRPE) {
      final totalVolumes = allExerciseLogs.map((log) {
        final volumes = log.sets.map((set) => (set as WeightAndRepsSetDto).volume());
        return volumes.sum;
      }).toList();
      volumeChartPoints = totalVolumes.mapIndexed((index, totalVolume) => ChartPointDto(index, totalVolume)).toList();

      final averageRpeRatings = allExerciseLogs.map((log) {
        final rpeRatings = log.sets.map((set) => set.rpeRating);
        return rpeRatings.average.ceil();
      }).toList();
      rpeChartPoints = averageRpeRatings.mapIndexed((index, rpeRating) => ChartPointDto(index, rpeRating)).toList();
      rpeColors = averageRpeRatings.map((rpeRating) => rpeIntensityToColor[rpeRating]!).toList();
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
                _metric == WeightVolumeRPE.weight
                    ? Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: LineChartWidget(
                            chartPoints: chartPoints, periods: [], unit: ChartUnit.weight, aspectRation: 2.5, reservedSize: 40,),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Stack(children: [
                          LineChartWidget(
                              chartPoints: volumeChartPoints, periods: [], unit: ChartUnit.weight, aspectRation: 2.5, reservedSize: 40,),
                          LineChartWidget(
                              chartPoints: rpeChartPoints,
                              periods: [],
                              unit: ChartUnit.number,
                              aspectRation: 2.5,
                              colors: rpeColors, lineChartSide: LineChartSide.right, reservedSize: 40,)
                        ]),
                      ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  child: Text(_metric.description,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          height: 1.8,
                          color: isDarkMode ? Colors.white70 : Colors.black)),
                ),
                CupertinoSlidingSegmentedControl<WeightVolumeRPE>(
                  backgroundColor: isDarkMode ? sapphireDark : Colors.grey.shade200,
                  thumbColor: isDarkMode ? sapphireDark80 : Colors.white,
                  groupValue: _metric,
                  children: {
                    WeightVolumeRPE.weight: SizedBox(
                        width: 50,
                        child: Text(WeightVolumeRPE.weight.name, style: textStyle, textAlign: TextAlign.center)),
                    WeightVolumeRPE.volumeRPE: SizedBox(
                        width: 100,
                        child: Text(WeightVolumeRPE.volumeRPE.name, style: textStyle, textAlign: TextAlign.center)),
                  },
                  onValueChanged: (WeightVolumeRPE? value) {
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
            ExerciseType.weights => DoubleSetHeader(firstLabel: weightLabel().toUpperCase(), secondLabel: 'REPS'),
            ExerciseType.bodyWeight => SingleSetHeader(label: 'REPS'),
            ExerciseType.duration => SingleSetHeader(label: 'TIME'),
          },
          SetsListview(type: exerciseType, sets: widget.exerciseLog.sets, pbs: pbs)
        ],
      ),
    );
  }
}

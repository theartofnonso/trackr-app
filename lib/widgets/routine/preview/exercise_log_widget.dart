import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/widgets/routine/preview/sets_listview.dart';

import '../../../controllers/exercise_and_routine_controller.dart';
import '../../../dtos/graph/chart_point_dto.dart';
import '../../../enums/chart_unit_enum.dart';
import '../../../screens/exercise/history/exercise_home_screen.dart';
import '../../../utils/exercise_logs_utils.dart';
import '../../../utils/general_utils.dart';
import '../../chart/line_chart_widget.dart';
import '../preview/set_headers/double_set_header.dart';
import '../preview/set_headers/single_set_header.dart';

class ExerciseLogWidget extends StatelessWidget {
  final ExerciseLogDto exerciseLog;
  final ExerciseLogDto? superSet;

  const ExerciseLogWidget({super.key, required this.exerciseLog, this.superSet});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final otherSuperSet = superSet;

    final exercise = exerciseLog.exercise;

    final exerciseType = exercise.type;

    final routineLogController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    final pastExerciseLogs =
        routineLogController.whereExerciseLogsBefore(exercise: exercise, date: exerciseLog.createdAt);

    final allExerciseLogs = routineLogController.exerciseLogsByExerciseId[exercise.id] ?? [];

    final pbs = calculatePBs(pastExerciseLogs: pastExerciseLogs, exerciseType: exerciseType, exerciseLog: exerciseLog);

    final repRange = getRepRange(exerciseLog: exerciseLog);

    final minReps = repRange.$1;

    final maxReps = repRange.$2;

    List<ChartPointDto> chartPoints = [];

    if (exerciseType == ExerciseType.weights) {
      final sets = allExerciseLogs.map((log) => heaviestWeightInSetForExerciseLog(exerciseLog: log)).toList();

      chartPoints = sets.mapIndexed((index, set) => ChartPointDto(index, (set).weight)).toList();
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => ExerciseHomeScreen(exercise: exerciseLog.exercise)));
      },
      child: Column(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(exerciseLog.exercise.name,
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
          if (exerciseLog.notes.isNotEmpty)
            Text(exerciseLog.notes, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
          Row(
            spacing: 4,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("$minReps"),
              FaIcon(
                FontAwesomeIcons.arrowRight,
                size: 12,
              ),
              Text("$maxReps REPS"),
            ],
          ),
          if (chartPoints.isNotEmpty)
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDarkMode ? Colors.white10 : Colors.black38, // Border color
                  width: 1.0, // Border width
                ),
                borderRadius: BorderRadius.circular(5), // Optional: Rounded corners
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: LineChartWidget(
                        chartPoints: chartPoints, periods: [], unit: ChartUnit.weight, aspectRation: 2.5),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                        "Track your heaviest weight lifted for ${exercise.name}. An upward trend highlights your strength gains and consistent improvement over time.",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            height: 1.8,
                            color: isDarkMode ? Colors.white70 : Colors.black)),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          switch (exerciseType) {
            ExerciseType.weights => DoubleSetHeader(firstLabel: weightLabel().toUpperCase(), secondLabel: 'REPS'),
            ExerciseType.bodyWeight => SingleSetHeader(label: 'REPS'),
            ExerciseType.duration => SingleSetHeader(label: 'TIME'),
          },
          SetsListview(type: exerciseType, sets: exerciseLog.sets, pbs: pbs)
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/widgets/routine/preview/sets_listview.dart';

import '../../../controllers/exercise_and_routine_controller.dart';
import '../../../screens/exercise/history/exercise_home_screen.dart';
import '../../../utils/exercise_logs_utils.dart';
import '../../../utils/general_utils.dart';
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

    final exerciseType = exerciseLog.exercise.type;

    final routineLogController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    final pastExerciseLogs =
        routineLogController.whereExerciseLogsBefore(exercise: exerciseLog.exercise, date: exerciseLog.createdAt);

    final pbs = calculatePBs(pastExerciseLogs: pastExerciseLogs, exerciseType: exerciseType, exerciseLog: exerciseLog);

    final repRange = getRepRange(exerciseLog: exerciseLog);

    final minReps = repRange.$1;

    final maxReps = repRange.$2;

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
          switch (exerciseType) {
            ExerciseType.weights => DoubleSetHeader(firstLabel: weightLabel().toUpperCase(), secondLabel: 'REPS'),
            ExerciseType.bodyWeight => SingleSetHeader(label: 'REPS'),
            ExerciseType.duration => SingleSetHeader(label: 'TIME'),
          },
          SetsListview(
              type: exerciseType,
              sets: exerciseLog.sets,
              pbs: pbs,
              borderColor: isDarkMode ? Colors.white10 : Colors.grey.shade400)
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/widgets/routine/preview/sets_listview.dart';

import '../../../controllers/exercise_and_routine_controller.dart';
import '../../../utils/exercise_logs_utils.dart';
import '../../../utils/general_utils.dart';
import '../preview/set_headers/double_set_header.dart';
import '../preview/set_headers/single_set_header.dart';
import '../pickers/workout_template_picker.dart';

enum StrengthStatus {
  improving(
    description:
        "🌟 You're getting stronger! Handling more volume with less effort shows fantastic adaptation. "
        "Keep that momentum going and consider increasing the challenge next session—just remember to watch your recovery.",
  ),
  declining(
    description:
        "📉 You're feeling a dip in strength. Double-check your sleep, nutrition, and stress levels—"
        "a little extra rest or a small load reduction can help you bounce back stronger!",
  ),
  maintaining(
    description:
        "🔄 Solid consistency! You've maintained performance levels well. "
        "Focus on refining technique and mind-muscle connection to build a perfect foundation for future gains.",
  ),
  potentialOvertraining(
    description:
        "⚠️ Easy there—your body might be on the verge of overtraining. "
        "Consider a short deload or reduce your training volume for a week to fully recover, then ramp back up gradually.",
  ),
  none(
    description: "🤔 We don't have enough data yet to analyze your progress. "
        "Keep logging sessions, and we'll give you tailored feedback as you go!",
  ),
  insufficient(
      description:
          "You’ve logged only one training. Great job! Log more sessions to identify trends over time.");

  const StrengthStatus({required this.description});

  final String description;
}

class ExerciseLogWidget extends StatefulWidget {
  final ExerciseLogDto exerciseLog;
  final ExerciseLogDto? superSet;

  const ExerciseLogWidget(
      {super.key, required this.exerciseLog, this.superSet});

  @override
  State<ExerciseLogWidget> createState() => _ExerciseLogWidgetState();
}

class _ExerciseLogWidgetState extends State<ExerciseLogWidget> {
  @override
  Widget build(BuildContext context) {
    final otherSuperSet = widget.superSet;

    final exercise = widget.exerciseLog.exercise;

    final exerciseType = exercise.type;

    final routineLogController =
        Provider.of<ExerciseAndRoutineController>(context, listen: false);

    final pastExerciseLogs = routineLogController.whereExerciseLogsBefore(
        exercise: exercise,
        date: widget.exerciseLog
            .createdAt); // Finds exercise logs by name from workout logs

    routineLogController.wherePrevSetsForExercise(
        exercise: exercise); // Finds sets by exercise name from workout logs

    final pbs = calculatePBs(
        pastExerciseLogs: pastExerciseLogs,
        exerciseType: exerciseType,
        exerciseLog: widget.exerciseLog);

    List<ExerciseLogDto> allExerciseLogs =
        routineLogController.exerciseLogsByExerciseId[exercise.id] ?? [];

    if (allExerciseLogs.length >= 5) {
      allExerciseLogs =
          allExerciseLogs.reversed.toList().sublist(0, 5).reversed.toList();
    } else {
      allExerciseLogs =
          allExerciseLogs.reversed.toList().sublist(0).reversed.toList();
    }

    return GestureDetector(
      onTap: () {
        showWorkoutTemplatePicker(
          context: context,
          exerciseName: exercise.name,
          title: "Workouts with ${exercise.name}",
        );
      },
      child: Column(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(widget.exerciseLog.exercise.name,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
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
                Text(otherSuperSet.exercise.name,
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          Column(
            children: [
              switch (exerciseType) {
                ExerciseType.weights => DoubleSetHeader(
                    firstLabel: weightUnit().toUpperCase(),
                    secondLabel: 'REPS'),
                ExerciseType.bodyWeight => SingleSetHeader(label: 'REPS'),
                ExerciseType.duration => SingleSetHeader(label: 'TIME'),
              },
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SetsListview(
                    type: exerciseType,
                    sets: widget.exerciseLog.sets,
                    pbs: pbs),
              )
            ],
          )
        ],
      ),
    );
  }
}

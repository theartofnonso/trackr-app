import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../colors.dart';
import '../../../controllers/exercise_and_routine_controller.dart';
import '../../../dtos/appsync/routine_log_dto.dart';
import '../../../utils/exercise_logs_utils.dart';
import '../../../utils/navigation_utils.dart';
import '../../../utils/string_utils.dart';
import '../../list_tiles/list_tile_solid.dart';
import '../../pbs/pb_icon.dart';

class RoutineLogWidget extends StatelessWidget {
  final RoutineLogDto log;
  final Color color;
  final String trailing;
  final bool isEditable;

  const RoutineLogWidget(
      {super.key, required this.log, required this.color, required this.trailing, this.isEditable = true});

  @override
  Widget build(BuildContext context) {
    final routineLogController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    final pbs = log.exerciseLogs.map((exerciseLog) {
      final pastExerciseLogs =
          routineLogController.whereExerciseLogsBefore(exercise: exerciseLog.exercise, date: exerciseLog.createdAt);

      return calculatePBs(
          pastExerciseLogs: pastExerciseLogs, exerciseType: exerciseLog.exercise.type, exerciseLog: exerciseLog);
    }).expand((pbs) => pbs);

    final completedExerciseLogsAndSets = completedExercises(exerciseLogs: log.exerciseLogs);

    return SolidListTile(
        title: log.name,
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: vibrantGreen, // Background color
            borderRadius: BorderRadius.circular(5), // Rounded corners
          ),
          child: Image.asset(
            'icons/dumbbells.png',
            fit: BoxFit.contain,
            height: 24, color: sapphireDark, // Adjust the height as needed
          ),
        ),
        subtitle:
            "${completedExerciseLogsAndSets.length} ${pluralize(word: "exercise", count: completedExerciseLogsAndSets.length)}",
        trailing: trailing,
        tileColor: color,
        trailingSubtitle: pbs.isNotEmpty ? PBIcon(color: sapphireLight, label: "${pbs.length}") : null,
        onTap: () => navigateToRoutineLogPreview(context: context, log: log, isEditable: isEditable));
  }
}

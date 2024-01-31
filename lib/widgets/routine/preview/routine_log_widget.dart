import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../app_constants.dart';
import '../../../controllers/routine_log_controller.dart';
import '../../../dtos/routine_log_dto.dart';
import '../../../utils/exercise_logs_utils.dart';
import '../../../utils/navigation_utils.dart';
import '../../../utils/string_utils.dart';
import '../../list_tiles/list_tile_solid.dart';
import '../../pbs/pb_icon.dart';

class RoutineLogWidget extends StatelessWidget {
  final RoutineLogDto log;
  final Color? color;
  final String trailing;

  const RoutineLogWidget({super.key, required this.log, this.color, required this.trailing});

  @override
  Widget build(BuildContext context) {
    final routineLogController = Provider.of<RoutineLogController>(context, listen: false);

    final pbs = log.exerciseLogs.map((exerciseLog) {
      final pastExerciseLogs =
      routineLogController.whereExerciseLogsBefore(exercise: exerciseLog.exercise, date: exerciseLog.createdAt);

      return calculatePBs(
          pastExerciseLogs: pastExerciseLogs, exerciseType: exerciseLog.exercise.type, exerciseLog: exerciseLog);
    }).expand((pbs) => pbs);

    final completedExerciseLogsAndSets = exerciseLogsWithCheckedSets(exerciseLogs: log.exerciseLogs);

    return SolidListTile(
        title: log.name,
        subtitle: "${completedExerciseLogsAndSets.length} ${pluralize(word: "exercise", count: log.exerciseLogs.length)}",
        trailing: trailing,
        tileColor: color,
        trailingSubtitle: pbs.isNotEmpty ? PBIcon(color: tealBlueLight, label: "${pbs.length}") : null,
        onTap: () => navigateToRoutineLogPreview(context: context, log: log));
  }
}
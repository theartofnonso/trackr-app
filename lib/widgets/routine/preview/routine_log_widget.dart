import 'package:flutter/cupertino.dart';
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

  const RoutineLogWidget({super.key, required this.log, required this.color, required this.trailing, this.isEditable = true});

  @override
  Widget build(BuildContext context) {
    final routineLogController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    final pbs = log.exerciseLogs.map((exerciseLog) {
      final pastExerciseLogs =
          routineLogController.whereExerciseLogsBefore(exerciseVariant: exerciseLog.exerciseVariant, date: exerciseLog.createdAt);

      return calculatePBs(
          pastExerciseLogs: pastExerciseLogs, exerciseMetric: exerciseLog.exerciseVariant.metric, exerciseLog: exerciseLog);
    }).expand((pbs) => pbs);

    final completedExerciseLogsAndSets = completedExercises(exerciseLogs: log.exerciseLogs);

    return SolidListTile(
        title: log.name,
        subtitle:
            "${completedExerciseLogsAndSets.length} ${pluralize(word: "exercise", count: completedExerciseLogsAndSets.length)}",
        trailing: trailing,
        tileColor: color,
        trailingSubtitle: pbs.isNotEmpty ? PBIcon(color: sapphireLight, label: "${pbs.length}") : null,
        onTap: () => navigateToRoutineLogPreview(context: context, log: log, isEditable: isEditable));
  }
}

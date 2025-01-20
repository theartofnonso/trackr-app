import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/utils/general_utils.dart';

import '../../controllers/exercise_and_routine_controller.dart';
import '../../dtos/appsync/routine_log_dto.dart';
import '../../dtos/set_dtos/reps_dto.dart';
import '../../dtos/set_dtos/weight_and_reps_dto.dart';
import '../../utils/exercise_logs_utils.dart';
import '../../utils/string_utils.dart';

class MonthlyTrainingSummaryWidget extends StatelessWidget {
  final List<RoutineLogDto> routineLogs;
  final DateTime dateTime;

  const MonthlyTrainingSummaryWidget({
    super.key,
    required this.routineLogs,
    required this.dateTime,
  });

  @override
  Widget build(BuildContext context) {

    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final exerciseLogs = routineLogs
        .map((log) => loggedExercises(exerciseLogs: log.exerciseLogs))
        .expand((exerciseLogs) => exerciseLogs);

    final sets = exerciseLogs.expand((exercise) => exercise.sets);

    final numberOfSets = sets.length;
    final routineLogHoursInMilliSeconds = routineLogs.map((log) => log.duration().inMilliseconds).sum;
    final totalHours = Duration(milliseconds: routineLogHoursInMilliSeconds);

    final tonnage = exerciseLogs.map((log) {
      if (log.exercise.type == ExerciseType.weights) {
        final volume = log.sets.map((set) => (set as WeightAndRepsSetDto).volume()).sum;
        return volume;
      }
      return 0.0;
    }).sum;

    final totalVolume = volumeInKOrM(tonnage);

    final exerciseLogsWithReps = exerciseLogs.where((exerciseLog) => withReps(type: exerciseLog.exercise.type));
    final totalReps = exerciseLogsWithReps.map((log) {
      final reps = log.sets.map((set) {
        final exerciseType = log.exercise.type;
        if (exerciseType == ExerciseType.bodyWeight) {
          return (set as RepsSetDto).reps;
        } else if (exerciseType == ExerciseType.weights) {
          return (set as WeightAndRepsSetDto).reps;
        }
        return 0;
      }).sum;
      return reps;
    }).sum;

    final routineLogController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    final numberOfPbs = exerciseLogs.map((exerciseLog) {
      final pastExerciseLogs =
          routineLogController.whereExerciseLogsBefore(exercise: exerciseLog.exercise, date: exerciseLog.createdAt);

      return calculatePBs(
          pastExerciseLogs: pastExerciseLogs, exerciseType: exerciseLog.exercise.type, exerciseLog: exerciseLog);
    }).expand((pbs) => pbs);

    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        decoration: BoxDecoration(
          color: isDarkMode ? sapphireDark80 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text("Summary of ${dateTime.formattedFullMonth()} Training".toUpperCase(),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            Table(
              border: TableBorder.symmetric(inside: BorderSide(color: isDarkMode ? sapphireLighter.withValues(alpha:0.4) : Colors.grey.shade100, width: 2)),
              columnWidths: const <int, TableColumnWidth>{
                0: FlexColumnWidth(),
                1: FlexColumnWidth(),
                2: FlexColumnWidth(),
              },
              children: [
                TableRow(children: [
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Center(
                      child: _TableItem(
                          title: 'Sessions'.toUpperCase(),
                          subTitle: "${routineLogs.length}",
                          titleColor: logStreakColor(value: routineLogs.length / 12),
                          subTitleColor: logStreakColor(value: routineLogs.length / 12),
                          padding: const EdgeInsets.only(bottom: 20)),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Center(
                      child: _TableItem(
                          title: 'SETS',
                          subTitle: "$numberOfSets",
                          titleColor: Colors.white,
                          subTitleColor: Colors.white,
                          padding: const EdgeInsets.only(bottom: 20)),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Center(
                      child: _TableItem(
                          title: 'REPS',
                          subTitle: "$totalReps",
                          titleColor: Colors.white,
                          subTitleColor: Colors.white,
                          padding: const EdgeInsets.only(bottom: 20)),
                    ),
                  ),
                ]),
                TableRow(children: [
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Center(
                      child: _TableItem(
                          title: 'VOLUME',
                          subTitle: totalVolume,
                          titleColor: Colors.white,
                          subTitleColor: Colors.white,
                          padding: const EdgeInsets.only(top: 20)),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Center(
                      child: _TableItem(
                          title: 'HOURS',
                          subTitle: totalHours.hmDigital(),
                          titleColor: Colors.white,
                          subTitleColor: Colors.white,
                          padding: const EdgeInsets.only(top: 20)),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Center(
                      child: _TableItem(
                          title: 'Personal Bests'.toUpperCase(),
                          subTitle: "${numberOfPbs.length}",
                          titleColor: Colors.white,
                          subTitleColor: Colors.white,
                          padding: const EdgeInsets.only(top: 20)),
                    ),
                  ),
                ]),
              ],
            ),
          ],
        ));
  }
}

class _TableItem extends StatelessWidget {
  final String title;
  final String subTitle;
  final Color titleColor;
  final Color subTitleColor;
  final EdgeInsets? padding;

  const _TableItem({
    required this.title,
    required this.subTitle,
    required this.titleColor,
    required this.subTitleColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            subTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall,
          )
        ],
      ),
    );
  }
}

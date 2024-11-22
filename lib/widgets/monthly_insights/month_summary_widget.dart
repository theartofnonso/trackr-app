import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/dtos/sets_dtos/weight_and_reps_set_dto.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/utils/general_utils.dart';

import '../../controllers/exercise_and_routine_controller.dart';
import '../../dtos/appsync/routine_log_dto.dart';
import '../../dtos/sets_dtos/reps_set_dto.dart';
import '../../enums/exercise/set_type_enums.dart';
import '../../utils/exercise_logs_utils.dart';
import '../../utils/string_utils.dart';

class MonthSummaryWidget extends StatelessWidget {
  final List<RoutineLogDto> routineLogs;
  final DateTime dateTime;

  const MonthSummaryWidget({
    super.key,
    required this.routineLogs,
    required this.dateTime,
  });

  @override
  Widget build(BuildContext context) {
    final exerciseLogs = routineLogs
        .map((log) => completedExercises(exerciseLogs: log.exerciseLogs))
        .expand((exerciseLogs) => exerciseLogs);

    final sets = exerciseLogs.expand((exercise) => exercise.sets);

    final numberOfSets = sets.length;
    final routineLogHoursInMilliSeconds = routineLogs.map((log) => log.duration().inMilliseconds).sum;
    final totalHours = Duration(milliseconds: routineLogHoursInMilliSeconds);

    final tonnage = exerciseLogs.map((log) {
      final volume = log.sets.map((set) => (set as WeightAndRepsSetDTO).volume()).sum;
      return volume;
    }).sum;

    final totalVolume = volumeInKOrM(tonnage);

    final exerciseLogsWithReps =
        exerciseLogs.where((exerciseLog) => withReps(metric: exerciseLog.exerciseVariant.getSetTypeConfiguration()));
    final totalReps = exerciseLogsWithReps.map((log) {
      final reps = log.sets.map((set) {
        final metric = log.exerciseVariant.getSetTypeConfiguration();
        if (metric == SetType.reps) {
          return (set as RepsSetDTO).reps;
        } else if (metric == SetType.weightsAndReps) {
          return (set as WeightAndRepsSetDTO).reps;
        }
        return 0;
      }).sum;
      return reps;
    }).sum;

    final routineLogController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    final numberOfPbs = exerciseLogs.map((exerciseLog) {
      final pastExerciseLogs = routineLogController.whereExerciseLogsBefore(
          exerciseVariant: exerciseLog.exerciseVariant, date: exerciseLog.createdAt);

      return calculatePBs(
          pastExerciseLogs: pastExerciseLogs,
          setType: exerciseLog.exerciseVariant.getSetTypeConfiguration(),
          exerciseLog: exerciseLog);
    }).expand((pbs) => pbs);

    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 20),
        decoration: BoxDecoration(
          color: sapphireDark80,
          border: Border.all(color: sapphireDark80.withOpacity(0.8), width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text("Summary of ${dateTime.formattedFullMonth()} Training".toUpperCase(),
                style: GoogleFonts.ubuntu(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            Table(
              border: TableBorder.symmetric(inside: BorderSide(color: sapphireLighter.withOpacity(0.4), width: 2)),
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
                          title: 'Days'.toUpperCase(),
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
            style: GoogleFonts.ubuntu(
              color: titleColor,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.ubuntu(
              color: subTitleColor.withOpacity(0.6),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }
}

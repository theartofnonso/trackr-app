import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/utils/general_utils.dart';

import '../../controllers/routine_log_controller.dart';
import '../../dtos/routine_log_dto.dart';
import '../../utils/exercise_logs_utils.dart';
import '../../utils/string_utils.dart';

class ExercisesSetsHoursVolumeWidget extends StatelessWidget {
  final List<RoutineLogDto> monthAndLogs;

  const ExercisesSetsHoursVolumeWidget({super.key, required this.monthAndLogs,});

  @override
  Widget build(BuildContext context) {

    final exerciseLogs = monthAndLogs
        .map((log) => exerciseLogsWithCheckedSets(exerciseLogs: log.exerciseLogs))
        .expand((exerciseLogs) => exerciseLogs);

    final sets = exerciseLogs.expand((exercise) => exercise.sets);
    final numberOfExercises = exerciseLogs.length;
    final numberOfSets = sets.length;
    final totalHoursInMilliSeconds = monthAndLogs.map((log) => log.duration().inMilliseconds).sum;
    final totalHours = Duration(milliseconds: totalHoursInMilliSeconds);

    final exerciseLogsWithWeights = exerciseLogs.where((exerciseLog) => withWeightsOnly(type: exerciseLog.exercise.type));
    final tonnage = exerciseLogsWithWeights.map((log) {
      final volume = log.sets.map((set) => set.volume()).sum;
      return volume;
    }).sum;

    final totalVolume = volumeInKOrM(weightWithConversion(value: tonnage));

    final exerciseLogsWithReps = exerciseLogs.where((exerciseLog) => withReps(type: exerciseLog.exercise.type));
    final totalReps = exerciseLogsWithReps.map((log) {
      final reps = log.sets.map((set) => set.reps()).sum;
      return reps;
    }).sum;

    final routineLogController = Provider.of<RoutineLogController>(context, listen: false);

    final numberOfPbs = exerciseLogs.map((exerciseLog) {
      final pastExerciseLogs =
      routineLogController.whereExerciseLogsBefore(exercise: exerciseLog.exercise, date: exerciseLog.createdAt);

      return calculatePBs(
          pastExerciseLogs: pastExerciseLogs, exerciseType: exerciseLog.exercise.type, exerciseLog: exerciseLog);
    }).expand((pbs) => pbs);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Summary of Sessions".toUpperCase(),
            style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 20),
            decoration: BoxDecoration(
              color: sapphireLight,
              border: Border.all(color: sapphireDark.withOpacity(0.8), width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Table(
              border: TableBorder.symmetric(inside: BorderSide(color: sapphireDark.withOpacity(0.2), width: 2)),
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
                      child: SleepTimeColumn(
                          title: 'EXERCISES',
                          subTitle: "$numberOfExercises",
                          titleColor: Colors.white,
                          subTitleColor: Colors.white, padding: const EdgeInsets.only(bottom: 20)),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Center(
                      child: SleepTimeColumn(
                          title: 'SETS',
                          subTitle: "$numberOfSets",
                          titleColor: Colors.white,
                          subTitleColor: Colors.white, padding: const EdgeInsets.only(bottom: 20)),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Center(
                      child: SleepTimeColumn(
                          title: 'REPS',
                          subTitle: "$totalReps",
                          titleColor: Colors.white,
                          subTitleColor: Colors.white, padding: const EdgeInsets.only(bottom: 20)),
                    ),
                  ),
                ]),
                TableRow(children: [
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Center(
                      child: SleepTimeColumn(
                          title: 'VOLUME',
                          subTitle: totalVolume,
                          titleColor: Colors.white,
                          subTitleColor: Colors.white, padding: const EdgeInsets.only(top: 20)),
                    ),
                  ),TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Center(
                      child: SleepTimeColumn(
                          title: 'HOURS',
                          subTitle: totalHours.hmDigital(),
                          titleColor: Colors.white,
                          subTitleColor: Colors.white, padding: const EdgeInsets.only(top: 20)),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Center(
                      child: SleepTimeColumn(
                          title: 'Personal Bests',
                          subTitle: "${numberOfPbs.length}",
                          titleColor: Colors.white,
                          subTitleColor: Colors.white, padding: const EdgeInsets.only(top: 20)),
                    ),
                  ),
                ]),
              ],
            )),
      ],
    );
  }
}

class SleepTimeColumn extends StatelessWidget {
  final String title;
  final String subTitle;
  final Color titleColor;
  final Color subTitleColor;
  final EdgeInsets? padding;

  const SleepTimeColumn({
    super.key,
    required this.title,
    required this.subTitle,
    required this.titleColor,
    required this.subTitleColor, this.padding,
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
            style: GoogleFonts.montserrat(
              color: titleColor,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
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

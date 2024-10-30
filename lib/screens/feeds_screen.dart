import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/utils/string_utils.dart';
import 'package:tracker_app/widgets/routine/preview/date_duration_pb.dart';

import '../colors.dart';
import '../controllers/activity_log_controller.dart';
import '../controllers/routine_log_controller.dart';
import '../dtos/appsync/activity_log_dto.dart';
import '../dtos/appsync/routine_log_dto.dart';
import '../dtos/interface/log_interface.dart';
import '../enums/activity_type_enums.dart';
import '../utils/dialog_utils.dart';
import '../utils/exercise_logs_utils.dart';
import '../utils/navigation_utils.dart';
import '../widgets/chart/muscle_group_family_chart.dart';
import 'no_list_empty_state.dart';

class FeedsScreen extends StatelessWidget {
  final ScrollController scrollController;

  const FeedsScreen({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final routineLogController = Provider.of<RoutineLogController>(context, listen: true);

    final routineLogs = routineLogController.logs;

    final activityLogController = Provider.of<ActivityLogController>(context, listen: true);

    final activityLogs = activityLogController.logs;

    final allLogs = [...routineLogs, ...activityLogs].sorted((a, b) => b.createdAt.compareTo(a.createdAt)).toList();

    if (routineLogs.isEmpty) {
      return const NoListEmptyState(icon: FaIcon(
      FontAwesomeIcons.house,
      color: Colors.white12,
      size: 48,
    ),message: "It might feel quiet now, but new activities from your training will soon appear here.",);
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            sapphireDark60,
            sapphireDark,
          ],
        ),
      ),
      child: SafeArea(
          minimum: const EdgeInsets.all(10.0),
          child: ListView.separated(
              controller: scrollController,
              itemCount: allLogs.length,
              itemBuilder: (BuildContext context, int index) {
                final log = allLogs[index];
                final widget = log.type == LogType.routine
                    ? _RoutineLogFeedListItem(log: log as RoutineLogDto)
                    : _ActivityLogFeedListItem(log: log as ActivityLogDto);
                return widget;
              },
              separatorBuilder: (BuildContext context, int index) => Divider(color: Colors.white70.withOpacity(0.1)))),
    );
  }
}

class _RoutineLogFeedListItem extends StatelessWidget {
  final RoutineLogDto log;

  const _RoutineLogFeedListItem({required this.log});

  @override
  Widget build(BuildContext context) {
    final routineLogsController = Provider.of<RoutineLogController>(context, listen: false);

    final pbs = log.exerciseLogs.map((exerciseLog) {
      final pastExerciseLogs =
          routineLogsController.whereExerciseLogsBefore(exercise: exerciseLog.exercise, date: exerciseLog.createdAt);

      return calculatePBs(
          pastExerciseLogs: pastExerciseLogs, exerciseType: exerciseLog.exercise.type, exerciseLog: exerciseLog);
    }).expand((pbs) => pbs);

    final completedExerciseLogsAndSets = exerciseLogsWithCheckedSets(exerciseLogs: log.exerciseLogs);
    final updatedLog = log.copyWith(exerciseLogs: completedExerciseLogsAndSets);

    final muscleGroupFamilyFrequencyData =
        muscleGroupFamilyFrequency(exerciseLogs: updatedLog.exerciseLogs, includeSecondaryMuscleGroups: false);

    return GestureDetector(
      onTap: () => navigateToRoutineLogPreview(context: context, log: log),
      child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.all(10.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(log.name,
                  style: GoogleFonts.ubuntu(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)),
              subtitle: DateDurationPBWidget(dateTime: log.createdAt, duration: log.duration(), pbs: pbs.length, durationSince: true,),
              trailing: const _ProfileIcon(),
            ),
            SizedBox(
              width: double.infinity,
              child: RichText(
                  text: TextSpan(
                      text: "${log.exerciseLogs.length} ${pluralize(word: "Exercise", count: log.exerciseLogs.length)}",
                      style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500),
                      children: [
                    const TextSpan(text: " "),
                    TextSpan(
                        text:
                            "x${log.exerciseLogs.fold(0, (sum, e) => sum + e.sets.length)} ${pluralize(word: "Set", count: log.exerciseLogs.fold(0, (sum, e) => sum + e.sets.length))}",
                        style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500, color: Colors.white70, fontSize: 12))
                  ])),
            ),
            const SizedBox(height: 8),
            MuscleGroupFamilyChart(frequencyData: muscleGroupFamilyFrequencyData),
          ])),
    );
  }
}

class _ActivityLogFeedListItem extends StatelessWidget {
  final ActivityLogDto log;

  const _ActivityLogFeedListItem({required this.log});

  @override
  Widget build(BuildContext context) {
    final activityType = ActivityType.fromString(log.name);

    final image = activityType.image;

    return GestureDetector(
      onTap: () => showActivityBottomSheet(context: context, activity: log),
      child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.all(10.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            ListTile(
              horizontalTitleGap: 5,
              contentPadding: EdgeInsets.zero,
              leading: image != null
                  ? Image.asset(
                      'icons/$image.png',
                      fit: BoxFit.contain,
                      height: 24, // Adjust the height as needed
                    )
                  : FaIcon(activityType.icon, color: Colors.white),
              title: Text(log.name,
                  style: GoogleFonts.ubuntu(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)),
              subtitle: DateDurationPBWidget(dateTime: log.createdAt, duration: log.duration(), pbs: 0, durationSince: true),
              trailing: const _ProfileIcon(),
            ),
          ])),
    );
  }
}

class _ProfileIcon extends StatelessWidget {
  const _ProfileIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 40, // Width and height should be equal to make a perfect circle
        height: 40,
        decoration: BoxDecoration(
          color: sapphireDark80,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(5), // Optional border
          boxShadow: [
            BoxShadow(
              color: sapphireDark.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: const Center(child: FaIcon(FontAwesomeIcons.solidUser, color: Colors.white54, size: 12)));
  }
}

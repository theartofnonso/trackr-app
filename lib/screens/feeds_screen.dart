import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/utils/string_utils.dart';

import '../colors.dart';
import '../controllers/routine_log_controller.dart';
import '../dtos/appsync/routine_log_dto.dart';
import '../utils/exercise_logs_utils.dart';
import '../widgets/chart/muscle_group_family_chart.dart';
import '../widgets/pbs/pb_icon.dart';
import 'no_list.dart';

class FeedsScreen extends StatelessWidget {

  final ScrollController scrollController;

  const FeedsScreen({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final routineLogsProvider = Provider.of<RoutineLogController>(context, listen: true);

    final routineLogs = routineLogsProvider.logs.sorted((a, b) => b.createdAt.compareTo(a.createdAt));

    if (routineLogs.isEmpty) return const NoList();

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
              itemCount: routineLogs.length,
              itemBuilder: (BuildContext context, int index) {
                final routineLog = routineLogs[index];
                return _FeedListItem(log: routineLog);
              },
              separatorBuilder: (BuildContext context, int index) => Divider(color: Colors.white70.withOpacity(0.1)))),
    );
  }
}

class _FeedListItem extends StatelessWidget {
  final RoutineLogDto log;

  const _FeedListItem({required this.log});

  @override
  Widget build(BuildContext context) {
    final routineLogsController = Provider.of<RoutineLogController>(context, listen: true);

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

    return Container(
        padding: const EdgeInsets.all(10.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(log.name,
                style: GoogleFonts.ubuntu(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)),
            subtitle: Row(
              children: [
                const Icon(
                  Icons.date_range_rounded,
                  color: Colors.white,
                  size: 12,
                ),
                const SizedBox(width: 1),
                Text(log.createdAt.durationSinceOrDate(),
                    style: GoogleFonts.ubuntu(
                        color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w500, fontSize: 12)),
                const SizedBox(width: 10),
                const Icon(
                  Icons.access_time_rounded,
                  color: Colors.white,
                  size: 12,
                ),
                const SizedBox(width: 1),
                Text(log.duration().hmsAnalog(),
                    style: GoogleFonts.ubuntu(
                        color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w500, fontSize: 12)),
                const SizedBox(width: 10),
                pbs.isNotEmpty ? PBIcon(color: sapphireLight, label: "${pbs.length}") : const SizedBox.shrink()
              ],
            ),
            trailing: Container(
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
                child: const Center(child: FaIcon(FontAwesomeIcons.solidUser, color: Colors.white54, size: 12))),
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
        ]));
  }
}

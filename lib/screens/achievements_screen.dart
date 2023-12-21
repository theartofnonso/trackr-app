import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/models/ModelProvider.dart';
import 'package:tracker_app/providers/routine_log_provider.dart';

import '../app_constants.dart';
import '../dtos/exercise_log_dto.dart';
import '../enums/achievement_type_enums.dart';
import '../widgets/backgrounds/gradient_background.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  ({int difference, double progress}) _calculateProgress(
      {required BuildContext context, required AchievementType type}) {
    return switch (type) {
      AchievementType.days12 => _calculateDaysProgress(context: context, type: type),
      AchievementType.days30 => _calculateDaysProgress(context: context, type: type),
      AchievementType.days75 => _calculateDaysProgress(context: context, type: type),
      AchievementType.days100 => _calculateDaysProgress(context: context, type: type),
      AchievementType.supersetSpecialist => _calculateSuperSetSpecialistProgress(context: context),
      AchievementType.obsessed => _calculateObsessedProgress(context: context),
      _ => (progress: 0, difference: 0)
    };
  }

  ({int difference, double progress}) _calculateDaysProgress(
      {required BuildContext context, required AchievementType type}) {
    final logs = Provider.of<RoutineLogProvider>(context, listen: false).logs;
    final targetDays = switch (type) {
      AchievementType.days12 => 12,
      AchievementType.days30 => 30,
      AchievementType.days75 => 75,
      AchievementType.days100 => 100,
      _ => 0,
    };

    final difference = targetDays - logs.length;

    final progress = logs.length / targetDays;

    return (progress: progress, difference: difference < 0 ? 0 : difference);
  }

  ({int difference, double progress}) _calculateSuperSetSpecialistProgress({required BuildContext context}) {
    final logs = Provider.of<RoutineLogProvider>(context, listen: false).logs;

    int target = 20;
    // Count RoutineLogs with at least two exercises that have a non-null superSetId
    int count = 0;

    for (var log in logs) {
      int exercisesWithSuperSetId = log.procedures
          .map((json) => ExerciseLogDto.fromJson(routineLog: log, json: jsonDecode(json)))
          .where((exerciseLog) => exerciseLog.superSetId.isNotEmpty)
          .length;

      if (exercisesWithSuperSetId >= 2) {
        count++;
      }
    }

    final progress = count / target;
    final difference = target - count;

    return (progress: progress, difference: difference < 0 ? 0 : difference);
  }

  List<DateTimeRange> generateWeekRanges(DateTime startDate) {
    DateTime currentDate = DateTime.now();
    List<DateTimeRange> weekRanges = [];

    // Find the first day of the week for the given start date
    startDate = startDate.subtract(Duration(days: startDate.weekday - 1));

    while (startDate.isBefore(currentDate)) {
      DateTime endDate = startDate.add(const Duration(days: 6));
      endDate = endDate.isBefore(currentDate) ? endDate : currentDate;

      weekRanges.add(DateTimeRange(start: startDate, end: endDate));

      // Move to the next week
      startDate = endDate.add(const Duration(days: 1));
    }

    return weekRanges;
  }

  Map<DateTimeRange, List<RoutineLog>> mapWeeksToRoutineLogs(List<RoutineLog> routineLogs, List<DateTimeRange> weekRanges) {
    Map<DateTimeRange, List<RoutineLog>> result = {};

    for (var weekRange in weekRanges) {
      List<RoutineLog> routinesInWeek = routineLogs.where((log) =>
      log.createdAt.getDateTimeInUtc().isAfter(weekRange.start) && log.createdAt.getDateTimeInUtc().isBefore(weekRange.end.add(const Duration(days: 1))))
          .toList();

      result[weekRange] = routinesInWeek;
    }

    return result;
  }

  ({int difference, double progress}) _calculateObsessedProgress({required BuildContext context}) {
    final logs = Provider.of<RoutineLogProvider>(context, listen: false).logs.reversed.toList();

    DateTime startDate = logs.first.createdAt.getDateTimeInUtc(); // Replace with your desired start date
    List<DateTimeRange> weekRanges = generateWeekRanges(startDate);

    // Map each DateTimeRange to RoutineLogs falling within it
    Map<DateTimeRange, List<RoutineLog>> weekToRoutineLogs = mapWeeksToRoutineLogs(logs, weekRanges);

    weekToRoutineLogs.forEach((key, value) {
      print("Week: ${key.start} - ${key.end}");
      print("Routines: ${value.length}");
    });

    int target = 12;
    // Count routine logs within 12 consecutive weeks
    int count = weekToRoutineLogs.length;

    final progress = count / target;
    final difference = target - count;

    return (progress: progress, difference: difference < 0 ? 0 : difference);
  }

  List<Widget> _achievementToWidgets({required BuildContext context}) {
    return AchievementType.values.map((achievementType) {
      final achievement = _calculateProgress(context: context, type: achievementType);
      return _CListTile(
        title: achievementType.title,
        subtitle: achievementType.description,
        progressValue: achievement.progress,
        progressRemainder: achievement.difference,
        margin: const EdgeInsets.only(bottom: 10),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      const Positioned.fill(child: GradientBackground()),
      SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 10),
              Text("Achievements",
                  style: GoogleFonts.lato(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              Text("Keep logging your sessions to achieve milestones and unlock badges.",
                  style: GoogleFonts.lato(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 20),
              ..._achievementToWidgets(context: context),
            ]),
          ),
        ),
      )
    ]));
  }
}

class _CListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progressValue;
  final int progressRemainder;
  final EdgeInsets margin;

  const _CListTile(
      {required this.title,
      required this.subtitle,
      required this.progressValue,
      required this.progressRemainder,
      required this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(8),
        margin: margin,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0), //
            border: Border.all(color: tealBlueLighter, width: 2) // Set the border radius here
            ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title.toUpperCase(),
                          style: GoogleFonts.lato(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Text(subtitle, style: GoogleFonts.lato(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    color: progressRemainder == 0 ? Colors.green : Colors.white,
                    value: progressValue,
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    backgroundColor: tealBlueLighter,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text("$progressRemainder left", style: GoogleFonts.lato(color: Colors.white70, fontSize: 12)),
          ],
        ));
  }
}

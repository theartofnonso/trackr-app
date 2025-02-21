import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/milestones/milestone_dto.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import '../../enums/milestone_type_enums.dart';
import '../appsync/routine_log_dto.dart';

class WeeklyMilestone extends Milestone {
  final MuscleGroup muscleGroupFamily;

  WeeklyMilestone(
      {required super.id,
      required super.name,
      required super.caption,
      required super.description,
      required super.rule,
      required super.target,
      this.muscleGroupFamily = MuscleGroup.fullBody,
      required super.progress,
      required super.type});

  static List<Milestone> loadMilestones(
      {required List<RoutineLogDto> logs, required List<DateTimeRange> weeksInYear, required DateTime datetime}) {
    final mondayMilestone = WeeklyMilestone(
        id: 'NMAMC_002',
        name: 'Never Miss A Monday'.toUpperCase(),
        description:
            'Kickstart your week with energy and dedication. Commit to a Monday workout to set a positive tone for the days ahead, ensuring consistent progress towards your fitness goals.',
        caption: "Train every Monday",
        target: 16,
        progress: calculateMondayProgress(logs: logs, target: 16, weeks: weeksInYear, datetime: datetime),
        rule: "Log at least one training session every Monday for 16 consecutive weeks.",
        type: MilestoneType.weekly);

    final weekendMilestone = WeeklyMilestone(
        id: 'WWC_003',
        name: 'Weekend Warrior'.toUpperCase(),
        description:
            'Maximize your weekends by dedicating time to intense training sessions. Push your limits and achieve significant fitness milestones by committing to workouts every weekend.',
        caption: "Train every weekend",
        target: 16,
        progress: calculateWeekendProgress(logs: logs, target: 16, weeks: weeksInYear, datetime: datetime),
        rule: "Log at least one training session every weekend (Saturday or Sunday) for 16 consecutive weeks.",
        type: MilestoneType.weekly);

    return [mondayMilestone, weekendMilestone];
  }

  static (double, List<RoutineLogDto>) calculateMondayProgress(
      {required List<RoutineLogDto> logs,
      required int target,
      required List<DateTimeRange> weeks,
      required DateTime datetime}) {
    if (logs.isEmpty) return (0, []);

    List<RoutineLogDto> mondayLogs = [];
    final now = datetime;

    // Process weeks in reverse order (from most recent to oldest)
    for (final week in weeks.reversed) {
      final logsForTheWeek = logs.where(
        (log) => log.createdAt.isWithinRange(range: week),
      );

      final mondayLog = logsForTheWeek.firstWhereOrNull(
        (log) => log.createdAt.weekday == DateTime.monday,
      );

      if (mondayLog != null) {
        mondayLogs.add(mondayLog);
      } else {
        // Only reset the streak if the week is over
        if (week.end.isBefore(now)) {
          break; // Streak is broken
        }
      }

      // Stop if we have reached the target number of logs
      if (mondayLogs.length >= target) {
        break;
      }
    }

    final qualifyingLogs = mondayLogs.take(target).toList();
    final progress = qualifyingLogs.length / target;

    return (progress, qualifyingLogs);
  }

  static (double, List<RoutineLogDto>) calculateWeekendProgress(
      {required List<RoutineLogDto> logs,
      required int target,
      required List<DateTimeRange> weeks,
      required DateTime datetime}) {
    if (logs.isEmpty) return (0, []);

    List<RoutineLogDto> weekendLogs = [];
    DateTime now = datetime;

    for (var week in weeks) {
      // Skip weeks that haven't ended yet
      if (week.end.isAfter(now) || week.end.isAtSameMomentAs(now)) {
        // Check if the current week has passed the weekend
        if (now.weekday != DateTime.saturday && now.weekday != DateTime.sunday && now.weekday != DateTime.monday) {
          continue;
        } else {
          // Adjust the week to include only dates up to now
          week = DateTimeRange(start: week.start, end: now);
        }
      }

      final logsForTheWeek = logs.where((log) => log.createdAt.isWithinRange(range: week));

      final saturdayOrSundayLogs = logsForTheWeek
          .where((log) => log.createdAt.weekday == DateTime.saturday || log.createdAt.weekday == DateTime.sunday);

      if (saturdayOrSundayLogs.isNotEmpty) {
        weekendLogs.add(saturdayOrSundayLogs.first);
      } else {
        // Only reset if we haven't met the target yet and we're not in the current week
        if (weekendLogs.length < target && week.end.isBefore(now)) {
          weekendLogs = [];
        }
      }
    }

    final qualifyingLogs = weekendLogs.take(target).toList();

    final progress = qualifyingLogs.length / target;

    return (progress, qualifyingLogs);
  }

  // static (double, List<RoutineLogDto>) calculateLegProgress({
  //   required List<RoutineLogDto> logs,
  //   required int target,
  //   required List<DateTimeRange> weeks,
  //   required DateTime datetime,
  // }) {
  //   if (logs.isEmpty) return (0, []);
  //
  //   List<RoutineLogDto> legsLogs = [];
  //   DateTime now = datetime;
  //
  //   for (var week in weeks) {
  //
  //     // If the week hasn’t ended yet, skip it
  //     if (week.end.isAfter(now) || week.end.isAtSameMomentAs(now)) {
  //       continue;
  //     }
  //
  //     // Filter logs that occurred within this ended week
  //     final logsForTheWeek = logs.where((log) => log.createdAt.isWithinRange(range: week));
  //
  //     // Find the first log that has at least one legs exercise
  //     final legLog = logsForTheWeek.firstWhereOrNull((log) {
  //       final completedExerciseLogs = loggedExercises(exerciseLogs: log.exerciseLogs);
  //       return completedExerciseLogs.any((exerciseLog) {
  //         return exerciseLog.exercise.primaryMuscleGroup.family == MuscleGroup.legs;
  //       });
  //     });
  //
  //     if (legLog != null) {
  //       legsLogs.add(legLog);
  //     } else {
  //       // If no leg-day log was found this week, reset if we haven’t met target yet
  //       if (legsLogs.length < target) {
  //         legsLogs = [];
  //       }
  //     }
  //   }
  //
  //   final qualifyingLogs = legsLogs.take(target).toList();
  //   final progress = qualifyingLogs.length / target;
  //   return (progress, qualifyingLogs);
  // }
}

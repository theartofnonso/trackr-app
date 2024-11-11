import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/milestones/milestone_dto.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/utils/exercise_logs_utils.dart';

import '../../enums/milestone_type_enums.dart';
import '../../utils/date_utils.dart';
import '../appsync/routine_log_dto.dart';

class WeeklyMilestone extends Milestone {
  final MuscleGroupFamily muscleGroupFamily;

  WeeklyMilestone(
      {required super.id,
      required super.name,
      required super.caption,
      required super.description,
      required super.rule,
      required super.target,
      this.muscleGroupFamily = MuscleGroupFamily.none,
      required super.progress,
      required super.type});

  static List<Milestone> loadMilestones({required List<RoutineLogDto> logs}) {
    final dateRange = yearToDateTimeRange(datetime: DateTime.now());

    final weeksInYear = generateWeeksInRange(range: dateRange);

    final mondayMilestone = WeeklyMilestone(
        id: 'NMAMC_002',
        name: 'Never Miss A Monday'.toUpperCase(),
        description:
            'Kickstart your week with energy and dedication. Commit to a Monday workout to set a positive tone for the days ahead, ensuring consistent progress towards your fitness goals.',
        caption: "Train every Monday",
        target: 16,
        progress: _calculateMondayProgress(logs: logs, target: 16, weeks: weeksInYear),
        rule: "Log at least one training session every Monday for 16 consecutive weeks.",
        type: MilestoneType.weekly);

    final weekendMilestone = WeeklyMilestone(
        id: 'WWC_003',
        name: 'Weekend Warrior'.toUpperCase(),
        description:
            'Maximize your weekends by dedicating time to intense training sessions. Push your limits and achieve significant fitness milestones by committing to workouts every weekend.',
        caption: "Train every weekend",
        target: 16,
        progress: _calculateWeekendProgress(logs: logs, target: 16, weeks: weeksInYear),
        rule: "Log at least one training session every weekend (Saturday or Sunday) for 16 consecutive weeks.",
        type: MilestoneType.weekly);

    final legDayMilestone = WeeklyMilestone(
        id: 'NMALDC_001',
        name: 'Never Miss A Leg Day'.toUpperCase(),
        description:
            'Commit to your fitness goals by never skipping leg day. Strengthen your lower body through consistent training, enhancing your overall physique and performance.',
        caption: "Train legs weekly",
        target: 16,
        progress: _calculateLegProgress(logs: logs, target: 16, weeks: weeksInYear),
        muscleGroupFamily: MuscleGroupFamily.legs,
        rule: "Log at least one leg-focused training session every week for 16 consecutive weeks.",
        type: MilestoneType.weekly);

    return [mondayMilestone, weekendMilestone, legDayMilestone];
  }

  static (double, List<RoutineLogDto>) _calculateMondayProgress(
      {required List<RoutineLogDto> logs, required int target, required List<DateTimeRange> weeks}) {
    if (logs.isEmpty) return (0, []);

    List<RoutineLogDto> mondayLogs = [];
    for (final week in weeks) {
      final logsForTheWeek = logs.where((log) => log.createdAt.isWithinRange(range: week));
      final mondayLog = logsForTheWeek.firstWhereOrNull((log) => log.createdAt.weekday == DateTime.monday);
      if (mondayLog != null) {
        mondayLogs.add(mondayLog);
      } else {
        if (mondayLogs.length < target) {
          mondayLogs = [];
        }
      }
    }

    final qualifyingLogs = mondayLogs.take(target).toList();

    final progress = qualifyingLogs.length / target;

    return (progress, qualifyingLogs);
  }

  static (double, List<RoutineLogDto>) _calculateWeekendProgress(
      {required List<RoutineLogDto> logs, required int target, required List<DateTimeRange> weeks}) {
    if (logs.isEmpty) return (0, []);

    List<RoutineLogDto> weekendLogs = [];
    for (final week in weeks) {
      final logsForTheWeek = logs.where((log) => log.createdAt.isWithinRange(range: week));
      final saturdayOrSundayLogs = logsForTheWeek
          .where((log) => log.createdAt.weekday == DateTime.saturday || log.createdAt.weekday == DateTime.sunday);
      if (saturdayOrSundayLogs.isNotEmpty) {
        weekendLogs.addAll(saturdayOrSundayLogs);
      } else {
        if (weekendLogs.length < target) {
          weekendLogs = [];
        }
      }
    }

    final qualifyingLogs = weekendLogs.take(target).toList();

    final progress = qualifyingLogs.length / target;

    return (progress, qualifyingLogs);
  }

  static (double, List<RoutineLogDto>) _calculateLegProgress(
      {required List<RoutineLogDto> logs, required int target, required List<DateTimeRange> weeks}) {
    if (logs.isEmpty) return (0, []);

    List<RoutineLogDto> legsLogs = [];
    for (final week in weeks) {
      final logsForTheWeek = logs.where((log) => log.createdAt.isWithinRange(range: week));
      final legLog = logsForTheWeek.firstWhereOrNull((log) {
        final completedExerciseLogs = completedExercises(exerciseLogs: log.exerciseLogs);
        final hasLegLog = completedExerciseLogs.where((exerciseLog) {
          final primaryMuscleGroupFamily = exerciseLog.exercise.primaryMuscleGroup.family;
          final secondaryMuscleGroupFamilies =
              exerciseLog.exercise.secondaryMuscleGroups.map((muscleGroup) => muscleGroup.family);
          final muscleGroupFamilies = [primaryMuscleGroupFamily, ...secondaryMuscleGroupFamilies];
          return muscleGroupFamilies.contains(MuscleGroupFamily.legs);
        }).isNotEmpty;
        return hasLegLog;
      });
      if (legLog != null) {
        legsLogs.add(legLog);
      } else {
        if (legsLogs.length < target) {
          legsLogs = [];
        }
      }
    }

    final qualifyingLogs = legsLogs.take(target).toList();

    final progress = qualifyingLogs.length / target;

    return (progress, qualifyingLogs);
  }
}

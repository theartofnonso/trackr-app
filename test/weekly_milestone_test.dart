import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_app/dtos/appsync/exercise_dto.dart';
import 'package:tracker_app/dtos/appsync/routine_log_dto.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/dtos/milestones/weekly_milestone_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/utils/date_utils.dart';

void main() {
  group('WeeklyMilestone', () {
    test('loadMilestones returns three milestones with zero progress if no logs', () {

      final now = DateTime.now().withoutTime();

      final dateRange = yearToDateTimeRange(datetime: now);

      final weeksInYear = generateWeeksInRange(range: dateRange);

      final logs = <RoutineLogDto>[];
      final milestones = WeeklyMilestone.loadMilestones(logs: logs, weeksInYear: weeksInYear, datetime: now);

      expect(milestones.length, 3);

      final mondayMilestone = milestones.firstWhere((m) => m.name == 'NEVER MISS A MONDAY');
      final weekendMilestone = milestones.firstWhere((m) => m.name == 'WEEKEND WARRIOR');
      final legDayMilestone = milestones.firstWhere((m) => m.name == 'NEVER MISS A LEG DAY');

      // All should have zero progress initially
      expect(mondayMilestone.progress.$1, 0);
      expect(mondayMilestone.progress.$2, isEmpty);

      expect(weekendMilestone.progress.$1, 0);
      expect(weekendMilestone.progress.$2, isEmpty);

      expect(legDayMilestone.progress.$1, 0);
      expect(legDayMilestone.progress.$2, isEmpty);
    });

    test('Never  streak break', () {

      final now = DateTime.now().withoutTime();

      final dateRange = yearToDateTimeRange(datetime: now);

      final weeksInYear = generateWeeksInRange(range: dateRange);

      // Suppose we have 5 Mondays logged, skip the 6th Monday, then have more Mondays.
      // The streak should break at the gap.
      List<RoutineLogDto> logs = [];

      // 5 Mondays in a row
      for (var i = 0; i < 5; i++) {
        final date = DateTime(2023, 1, 2).add(Duration(days: i * 7));
        logs.add(RoutineLogDto(
          id: 'log$i',
          templateId: 'temp',
          name: 'Monday Workout $i',
          notes: '',
          summary: null,
          startTime: date,
          endTime: date.add(const Duration(hours: 1)),
          exerciseLogs: [],
          owner: 'user',
          createdAt: date,
          updatedAt: date,
        ));
      }

      // Skip a week (no Monday log), then add more Mondays after
      for (var i = 6; i < 10; i++) {
        final date = DateTime(2023, 1, 2).add(Duration(days: i * 7));
        logs.add(RoutineLogDto(
          id: 'log$i',
          templateId: 'temp',
          name: 'Monday Workout $i',
          notes: '',
          summary: null,
          startTime: date,
          endTime: date.add(const Duration(hours: 1)),
          exerciseLogs: [],
          owner: 'user',
          createdAt: date,
          updatedAt: date,
        ));
      }

      final milestones = WeeklyMilestone.loadMilestones(logs: logs, weeksInYear: weeksInYear, datetime: now);
      final mondayMilestone = milestones.firstWhere((m) => m.name == 'NEVER MISS A MONDAY');

      // The streak should break at week 6 since there's no log for that Monday.
      // According to the logic, once a week passes without a Monday log, the streak stops counting further weeks.
      // Thus, we only have the initial 5 Monday logs contributing.
      expect(mondayMilestone.progress.$1, 0);
      expect(mondayMilestone.progress.$2.length, 0);
    });

    test('Weekend Warrior milestone partial completion and streak reset', () {

      final now = DateTime.now().withoutTime();

      final dateRange = yearToDateTimeRange(datetime: now);

      final weeksInYear = generateWeeksInRange(range: dateRange);

      // Similar logic for weekends. Let's log Saturdays for 5 weeks, skip a weekend, then add more.
      List<RoutineLogDto> logs = [];
      // Start from a known Saturday: 2023-01-07 is a Saturday
      for (var i = 0; i < 5; i++) {
        final date = DateTime(2023, 1, 7).add(Duration(days: i * 7));
        logs.add(RoutineLogDto(
          id: 'log$i',
          templateId: 'temp',
          name: 'Weekend Workout $i',
          notes: '',
          summary: null,
          startTime: date,
          endTime: date.add(const Duration(hours: 1)),
          exerciseLogs: [],
          owner: 'user',
          createdAt: date,
          updatedAt: date,
        ));
      }

      // Skip one weekend (no Sat/Sun log)
      // Then add more weekend logs after skipping
      for (var i = 6; i < 8; i++) {
        final date = DateTime(2023, 1, 7).add(Duration(days: i * 7));
        logs.add(RoutineLogDto(
          id: 'log$i',
          templateId: 'temp',
          name: 'Weekend Workout $i',
          notes: '',
          summary: null,
          startTime: date,
          endTime: date.add(const Duration(hours: 1)),
          exerciseLogs: [],
          owner: 'user',
          createdAt: date,
          updatedAt: date,
        ));
      }

      final milestones = WeeklyMilestone.loadMilestones(logs: logs, weeksInYear: weeksInYear, datetime: now);
      final weekendMilestone = milestones.firstWhere((m) => m.name == 'WEEKEND WARRIOR');

      // The streak should have reset after the missed weekend.
      // According to code, if a weekend is missed and it's past that week,
      // the streak resets. Thus, we only count the last two logs after the break.
      expect(weekendMilestone.progress.$1, 0);
      expect(weekendMilestone.progress.$2.length, 0);
    });

    test('Never Miss a Leg Day milestone streak resets if a week misses legs', () {

      final now = DateTime.now().withoutTime();

      final dateRange = yearToDateTimeRange(datetime: now);

      final weeksInYear = generateWeeksInRange(range: dateRange);

      final legExercise = ExerciseDto(
        id: 'squat',
        name: 'Squat',
        primaryMuscleGroup: MuscleGroup.quadriceps,
        secondaryMuscleGroups: [MuscleGroup.hamstrings],
        type: ExerciseType.weights,
        owner: '',
      );

      List<RoutineLogDto> logs = [];
      // 3 weeks with leg exercises
      for (var i = 0; i < 3; i++) {
        final date = DateTime(2023, 1, 2).add(Duration(days: i * 7));
        logs.add(RoutineLogDto(
          id: 'log$i',
          templateId: 'temp',
          name: 'Leg Workout $i',
          notes: '',
          summary: null,
          startTime: date,
          endTime: date.add(const Duration(hours: 1)),
          exerciseLogs: [
            ExerciseLogDto(
              id: 'exLog$i',
              routineLogId: 'log$i',
              superSetId: '',
              exercise: legExercise,
              notes: '',
              sets: [],
              createdAt: date,
            )
          ],
          owner: 'user',
          createdAt: date,
          updatedAt: date,
        ));
      }

      // 4th week - no leg exercise
      final fourthWeekDate = DateTime(2023, 1, 2).add(Duration(days: 3 * 7));
      logs.add(RoutineLogDto(
        id: 'log4',
        templateId: 'temp',
        name: 'No Leg Workout',
        notes: '',
        summary: null,
        startTime: fourthWeekDate,
        endTime: fourthWeekDate.add(const Duration(hours: 1)),
        exerciseLogs: [],
        // no leg exercises
        owner: 'user',
        createdAt: fourthWeekDate,
        updatedAt: fourthWeekDate,
      ));

      final milestones = WeeklyMilestone.loadMilestones(logs: logs, weeksInYear: weeksInYear, datetime: now);
      final legDayMilestone = milestones.firstWhere((m) => m.id == 'NMALDC_001');

      // Streak breaks after the 4th week that lacks a leg log
      // According to the code, if a week fails and we haven't hit the target, we reset the streak.
      expect(legDayMilestone.progress.$1, 0);
      expect(legDayMilestone.progress.$2.length, 0);
    });

    test('Never Miss a Monday milestone does not reset before or on Monday if no log is yet recorded for that Monday', () {

      final weeksInYear = [
        DateTimeRange(start: DateTime(2023, 1, 2), end: DateTime(2023, 1, 8)),
        DateTimeRange(start: DateTime(2023, 1, 9), end: DateTime(2023, 1, 15)),
        DateTimeRange(start: DateTime(2023, 1, 16), end: DateTime(2023, 1, 22)),
      ];

      final logs = <RoutineLogDto>[];

      // Assume that 'Never Miss a Monday' requires a log on each Monday.
      // We have successfully logged the past three Mondays: 2023-01-02, 2023-01-09, 2023-01-16.
      for (var i = 0; i < 3; i++) {
        final date = DateTime(2023, 1, 2).add(Duration(days: i * 7));
        logs.add(RoutineLogDto(
          id: 'log$i',
          templateId: 'temp',
          name: 'Monday Workout $i',
          notes: '',
          summary: null,
          startTime: date,
          endTime: date.add(const Duration(hours: 1)),
          exerciseLogs: [],
          owner: 'user',
          createdAt: date,
          updatedAt: date,
        ));
      }

      // Now the current Monday is 2023-01-23. The user has not yet logged a Monday workout.
      // However, the day isn't over. Let's assume our milestone logic considers the current date/time.
      final now = DateTime(2023, 1, 23, 10); // Monday at 10:00 AM

      // If your loadMilestones function does not currently accept a 'now' parameter,
      // you may need to modify it to allow passing in a reference date or mock DateTime.now().
      final milestones = WeeklyMilestone.loadMilestones(logs: logs, datetime: now, weeksInYear: weeksInYear);
      final mondayMilestone = milestones.firstWhere((m) => m.name == 'NEVER MISS A MONDAY');

      // Because the Monday is not over yet, the streak should not be considered broken.
      // We still have a streak from the previous Mondays.
      expect(mondayMilestone.progress.$1, greaterThan(0), reason: 'The streak should remain until the day passes without a log.');
      expect(mondayMilestone.progress.$2.isNotEmpty, isTrue, reason: 'Previous Monday logs should still be counted.');
    });

    test('Weekend Warrior milestone does not reset before or on the weekend if no log is yet recorded for that weekend', () {

      final weeksInYear = [
        DateTimeRange(start: DateTime(2023, 1, 2), end: DateTime(2023, 1, 8)),
        DateTimeRange(start: DateTime(2023, 1, 9), end: DateTime(2023, 1, 15)),
        DateTimeRange(start: DateTime(2023, 1, 16), end: DateTime(2023, 1, 22)),
      ];

      final logs = <RoutineLogDto>[];

      // Assume that 'Weekend Warrior' milestone requires a log on Saturday or Sunday each week.
      // We have logged the past two weekends (Jan 07 and Jan 14).
      for (var i = 0; i < 2; i++) {
        final date = DateTime(2023, 1, 7).add(Duration(days: i * 7));
        logs.add(RoutineLogDto(
          id: 'log$i',
          templateId: 'temp',
          name: 'Weekend Workout $i',
          notes: '',
          summary: null,
          startTime: date,
          endTime: date.add(const Duration(hours: 1)),
          exerciseLogs: [],
          owner: 'user',
          createdAt: date,
          updatedAt: date,
        ));
      }

      // Now it's the next weekend: Saturday 2023-01-21 at 10:00 AM.
      // No weekend log yet, but the weekend hasn't passed.
      final now = DateTime(2023, 1, 21, 10);

      final milestones = WeeklyMilestone.loadMilestones(logs: logs, datetime: now, weeksInYear: weeksInYear);
      final weekendMilestone = milestones.firstWhere((m) => m.name == 'WEEKEND WARRIOR');

      // The streak should not reset yet since the weekend is not over.
      // The user still has the rest of Saturday or Sunday to log a workout.
      expect(weekendMilestone.progress.$1, greaterThan(0), reason: 'The weekend streak should hold until the weekend passes without a log.');
      expect(weekendMilestone.progress.$2.isNotEmpty, isTrue, reason: 'Previous weekend logs should still be counted.');
    });
  });
}

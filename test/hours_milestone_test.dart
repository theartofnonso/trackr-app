import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_app/dtos/appsync/routine_log_dto.dart';
import 'package:tracker_app/dtos/milestones/hours_milestone_dto.dart';
import 'package:tracker_app/enums/milestone_type_enums.dart';

void main() {
  group('HoursMilestone', () {
    test('loadMilestones returns a milestone for each HoursMilestoneEnums with zero progress if no logs', () {
      final logs = <RoutineLogDto>[];
      final milestones = HoursMilestone.loadMilestones(logs: logs);

      // We have three defined enums: 30, 50, 100 hours
      expect(milestones.length, 3);

      // Check each target
      final hoursTargets = [30, 50, 100];
      for (var target in hoursTargets) {
        final milestone = milestones.firstWhere((m) => m.target == target);
        expect(milestone.type, MilestoneType.hours);
        expect(milestone.progress.$1, 0);
        expect(milestone.progress.$2, isEmpty);
        // Name should match the enum's name to uppercase
        switch (target) {
          case 30:
            expect(milestone.name, 'GYM NEWBIE'.toUpperCase());
            break;
          case 50:
            expect(milestone.name, 'IRON INTERN'.toUpperCase());
            break;
          case 100:
            expect(milestone.name, 'SWEAT EQUITY'.toUpperCase());
            break;
        }
        expect(milestone.caption, 'Train for $target hours');
      }
    });

    test('no logs scenario returns zero progress', () {
      final (progress, qualifyingLogs) = HoursMilestone.calculateProgress(logs: [], hours: HoursMilestoneEnums.thirty);
      expect(progress, 0);
      expect(qualifyingLogs, isEmpty);
    });

    test('partial progress is calculated correctly when total hours are fewer than target', () {
      // Suppose we have total logs summing up to 10 hours but target is 30 hours
      // 10 hours in milliseconds: 10 * 3600000
      final logs = List.generate(10, (index) {
        // Each log is 1 hour long: startTime=0:00, endTime=1:00
        return RoutineLogDto(
          id: 'log$index',
          templateId: 'temp',
          name: 'Workout $index',
          notes: '',
          summary: null,
          startTime: DateTime(2023, 1, 1, index),
          // start at index:00
          endTime: DateTime(2023, 1, 1, index + 1),
          // end at index+1:00
          exerciseLogs: [],
          owner: 'user',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      });

      final (progress, qualifyingLogs) =
          HoursMilestone.calculateProgress(logs: logs, hours: HoursMilestoneEnums.thirty);
      expect(progress, 10 / 30);
      expect(qualifyingLogs.length, 10);
      expect(qualifyingLogs, logs);
    });

    test('exact progress when logs match target exactly', () {
      // Suppose we need exactly 30 hours: create 30 logs of 1 hour each
      final logs = List.generate(30, (index) {
        return RoutineLogDto(
          id: 'log$index',
          templateId: 'temp',
          name: 'Workout $index',
          notes: '',
          summary: null,
          startTime: DateTime(2023, 1, 1, index),
          endTime: DateTime(2023, 1, 1, index + 1),
          exerciseLogs: [],
          owner: 'user',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      });

      final (progress, qualifyingLogs) = HoursMilestone.calculateProgress(
        logs: logs,
        hours: HoursMilestoneEnums.thirty,
      );
      expect(progress, 1.0);
      expect(qualifyingLogs.length, 30);
      expect(qualifyingLogs, logs);
    });

    test('progress caps at 1.0 if total hours exceed target', () {
      // Suppose target is 30 hours, but we have 40 hours worth of logs
      final logs = List.generate(40, (index) {
        return RoutineLogDto(
          id: 'log$index',
          templateId: 'temp',
          name: 'Workout $index',
          notes: '',
          summary: null,
          startTime: DateTime(2023, 1, 1, index),
          endTime: DateTime(2023, 1, 1, index + 1),
          exerciseLogs: [],
          owner: 'user',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      });

      final (progress, qualifyingLogs) = HoursMilestone.calculateProgress(
        logs: logs,
        hours: HoursMilestoneEnums.thirty,
      );
      expect(progress, 1.0);
      // Only the first 30 logs should be considered to reach the target
      expect(qualifyingLogs.length, 30);
      expect(qualifyingLogs, logs.take(30).toList());
    });

    test('loadMilestones integrates correctly with _calculateProgress', () {
      // Test scenario: 50-hour milestone and we have exactly 50 hours of logs
      final logs = List.generate(50, (index) {
        return RoutineLogDto(
          id: 'log$index',
          templateId: 'temp',
          name: 'Workout $index',
          notes: '',
          summary: null,
          startTime: DateTime(2023, 1, 1, index),
          endTime: DateTime(2023, 1, 1, index + 1),
          exerciseLogs: [],
          owner: 'user',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      });

      final milestones = HoursMilestone.loadMilestones(logs: logs);

      // Check the 50-hour milestone
      final fiftyHourMilestone = milestones.firstWhere((m) => m.target == 50);
      final (progress, qualifyingLogs) = fiftyHourMilestone.progress;

      expect(progress, 1.0);
      expect(qualifyingLogs.length, 50);
      expect(qualifyingLogs, logs);
    });
  });
}

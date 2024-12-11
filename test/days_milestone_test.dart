import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_app/dtos/appsync/routine_log_dto.dart';
import 'package:tracker_app/dtos/milestones/days_milestone_dto.dart';
import 'package:tracker_app/enums/milestone_type_enums.dart';

void main() {
  group('DaysMilestone', () {
    test('loadMilestones returns a milestone for each DaysMilestoneEnums value with zero progress if no logs', () {
      final logs = <RoutineLogDto>[];
      final milestones = DaysMilestone.loadMilestones(logs: logs);

      // We have three defined enums: 30, 50, 100 days
      expect(milestones.length, 3);

      final daysTargets = [30, 50, 100];

      for (var target in daysTargets) {
        final milestone = milestones.firstWhere((m) => m.target == target);
        expect(milestone.type, MilestoneType.days);
        expect(milestone.progress.$1, 0);
        expect(milestone.progress.$2, isEmpty);
        expect(milestone.name, '$target DAYS OF GAINS');
        expect(milestone.caption, 'Train for $target days');
      }
    });

    test('calculate progress with no logs is zero', () {
      final milestones = DaysMilestone.loadMilestones(logs: []);
      for (final milestone in milestones) {
        final (progress, qualifyingLogs) = milestone.progress;
        expect(progress, 0);
        expect(qualifyingLogs, isEmpty);
      }
    });

    test('partial progress is calculated correctly when logs are fewer than target', () {
      // Suppose we have 10 logs but target is 30
      final logs = List.generate(10, (index) {
        return RoutineLogDto(
          id: 'log$index',
          templateId: 'temp',
          name: 'Workout $index',
          notes: '',
          summary: null,
          startTime: DateTime.now(),
          endTime: DateTime.now(),
          exerciseLogs: [],
          owner: 'user',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      });

      final (progress, qualifyingLogs) = DaysMilestone.calculateLogsAndProgress(logs: logs, target: 30);
      expect(progress, 10 / 30);
      expect(qualifyingLogs.length, 10);

      // The logs returned should match the first 10 logs (since we have only 10)
      expect(qualifyingLogs, logs);
    });

    test('exact progress when logs match target', () {
      // Suppose we have 30 logs and target is 30
      final logs = List.generate(30, (index) {
        return RoutineLogDto(
          id: 'log$index',
          templateId: 'temp',
          name: 'Workout $index',
          notes: '',
          summary: null,
          startTime: DateTime.now(),
          endTime: DateTime.now(),
          exerciseLogs: [],
          owner: 'user',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      });

      final (progress, qualifyingLogs) = DaysMilestone.calculateLogsAndProgress(logs: logs, target: 30);
      expect(progress, 1.0); // Exactly at target
      expect(qualifyingLogs.length, 30);
      expect(qualifyingLogs, logs);
    });

    test('progress caps at 1.0 even if more logs than target are provided', () {
      // Suppose we have 40 logs but target is 30
      final logs = List.generate(40, (index) {
        return RoutineLogDto(
          id: 'log$index',
          templateId: 'temp',
          name: 'Workout $index',
          notes: '',
          summary: null,
          startTime: DateTime.now(),
          endTime: DateTime.now(),
          exerciseLogs: [],
          owner: 'user',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      });

      final (progress, qualifyingLogs) = DaysMilestone.calculateLogsAndProgress(logs: logs, target: 30);
      expect(progress, 1.0);
      // Only the first 30 logs should be returned
      expect(qualifyingLogs.length, 30);
      expect(qualifyingLogs, logs.take(30).toList());
    });

    test('loadMilestones integrates correctly with _calculateLogsAndProgress', () {
      // Test a scenario with 50 logs for a 50-day milestone
      final logs = List.generate(50, (index) {
        return RoutineLogDto(
          id: 'log$index',
          templateId: 'temp',
          name: 'Workout $index',
          notes: '',
          summary: null,
          startTime: DateTime.now(),
          endTime: DateTime.now(),
          exerciseLogs: [],
          owner: 'user',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      });

      final milestones = DaysMilestone.loadMilestones(logs: logs);

      // Check the 50-day milestone
      final fiftyDayMilestone = milestones.firstWhere((m) => m.target == 50);
      final (progress, qualifyingLogs) = fiftyDayMilestone.progress;

      expect(progress, 1.0);
      expect(qualifyingLogs.length, 50);
    });
  });
}

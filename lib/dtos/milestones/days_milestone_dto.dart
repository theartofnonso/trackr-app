import 'package:collection/collection.dart';
import 'package:tracker_app/dtos/appsync/routine_log_dto.dart';

import '../../enums/milestone_type_enums.dart';
import 'milestone_dto.dart';

enum DaysMilestoneEnums {
  thirty(30),
  fifty(50),
  hundred(100);

  final int length;

  const DaysMilestoneEnums(this.length);
}

class DaysMilestone extends Milestone {
  DaysMilestone(
      {required super.id,
      required super.name,
      required super.caption,
      required super.description,
      required super.rule,
      required super.target,
      required super.progress,
      required super.type});

  static List<Milestone> loadMilestones({required List<RoutineLogDto> logs}) {
    final days = DaysMilestoneEnums.values;

    return days.mapIndexed((index, days) {
      final description =
          'Prove your dedication by logging ${days.length} days of training. This challenge is for the truly committed.';
      final caption = 'Train for ${days.length} days';
      final rule = 'Log ${days.length} days of training to complete this ${days.length}-Day Challenge.';
      final loadLogsAndProgress = _calculateLogsAndProgress(logs: logs, target: days.length);
      final _ = loadLogsAndProgress.$1;
      final progress = loadLogsAndProgress.$2;
      return DaysMilestone(
          id: "Days_Milestone_${days.length}_$index",
          name: '${days.length} Days of Gains'.toUpperCase(),
          caption: caption,
          description: description,
          rule: rule,
          target: days.length,
          progress: progress,
          type: MilestoneType.days);
    }).toList();
  }

  static (List<RoutineLogDto>, double) _calculateLogsAndProgress({required List<RoutineLogDto> logs, required int target}) {
    final listOfLogs = logs.take(target);
    final progress = listOfLogs.length / target;
    return (listOfLogs.take(target).toList(), progress);
  }
}

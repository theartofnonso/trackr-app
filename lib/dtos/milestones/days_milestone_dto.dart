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
      final loadLogsAndProgress = calculateLogsAndProgress(logs: logs, target: days.length);
      return DaysMilestone(
          id: "Days_Milestone_${days.length}_$index",
          name: '${days.length} Days of Gains'.toUpperCase(),
          caption: caption,
          description: description,
          rule: rule,
          target: days.length,
          progress: loadLogsAndProgress,
          type: MilestoneType.days);
    }).toList();
  }

  static (double, List<RoutineLogDto>) calculateLogsAndProgress({required List<RoutineLogDto> logs, required int target}) {

    if(logs.isEmpty) return (0, []);

    final qualifyingLogs = logs.take(target);
    final progress = qualifyingLogs.length / target;
    return (progress, qualifyingLogs.toList());
  }
}

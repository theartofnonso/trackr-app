import 'package:collection/collection.dart';

import '../../enums/milestone_type_enums.dart';
import '../appsync/routine_log_dto.dart';
import 'milestone_dto.dart';

enum HoursMilestoneEnums {
  thirty(30, "Gym Newbie"),
  fifty(50, "Iron Intern"),
  hundred(100, "Sweat Equity");

  final int duration;
  final String name;

  const HoursMilestoneEnums(this.duration, this.name);
}

class HoursMilestone extends Milestone {
  HoursMilestone(
      {required super.id,
      required super.name,
      required super.caption,
      required super.description,
      required super.rule,
      required super.target,
      required super.progress,
      required super.type});

  static List<Milestone> loadMilestones({required List<RoutineLogDto> logs}) {
    final days = HoursMilestoneEnums.values;

    return days.mapIndexed((index, hours) {
      final description =
          'Prove your dedication by logging ${hours.duration} hours of training. This challenge is for the truly committed.';
      final caption = 'Train for ${hours.duration} hours';
      final rule = 'Log ${hours.duration} hours of training to complete this ${hours.duration}-Hour Challenge.';
      return HoursMilestone(
          id: "Days_Milestone_${hours.duration}_$index",
          name: hours.name.toUpperCase(),
          caption: caption,
          description: description,
          rule: rule,
          target: hours.duration,
          progress: calculateProgress(
            logs: logs,
            hours: hours,
          ),
          type: MilestoneType.hours);
    }).toList();
  }

  static (double, List<RoutineLogDto>) calculateProgress(
      {required List<RoutineLogDto> logs, required HoursMilestoneEnums hours}) {
    final targetDurationInMilliseconds = hours.duration * 3600000;

    int durationInMilliseconds = 0;
    List<RoutineLogDto> qualifyingLogs = [];

    for (final log in logs) {
      if (durationInMilliseconds < targetDurationInMilliseconds) {
        durationInMilliseconds += log.duration().inMilliseconds;

        qualifyingLogs.add(log);
      }
    }

    final progress = (durationInMilliseconds >= targetDurationInMilliseconds
            ? 1
            : durationInMilliseconds / targetDurationInMilliseconds)
        .toDouble();

    return (progress, qualifyingLogs);
  }
}

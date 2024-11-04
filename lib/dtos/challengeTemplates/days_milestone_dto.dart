import 'package:collection/collection.dart';

import '../../enums/milestone_type_enums.dart';
import 'milestone_dto.dart';

enum DaysMilestoneEnums {
  thirty(30),
  fifty(50),
  hundred(100);

  final int value;

  const DaysMilestoneEnums(this.value);
}

class DaysMilestone extends Milestone {
  DaysMilestone(
      {required super.id,
      required super.name,
      required super.caption,
      required super.description,
      required super.rule,
      required super.target,
      required super.type});

  static List<Milestone> loadMilestones() {
    final days = DaysMilestoneEnums.values;

    return days.mapIndexed((index, days) {
      final description =
          'Prove your dedication by logging ${days.value} days of training. This challenge is for the truly committed.';
      final caption = 'Train for ${days.value} days';
      final rule = 'Log ${days.value} days of training to complete this 100-Day Challenge.';
      return DaysMilestone(
          id: "Days_Milestone_${days.value}_$index",
          name: '${days.value} Days of Gains'.toUpperCase(),
          caption: caption,
          description: description,
          rule: rule,
          target: 10000,
          type: MilestoneType.days);
    }).toList();
  }
}

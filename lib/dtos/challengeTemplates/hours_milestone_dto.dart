import 'package:collection/collection.dart';

import '../../enums/milestone_type_enums.dart';
import 'milestone_dto.dart';

enum HoursMilestoneEnums {
  thirty(30, "Gym Newbie"),
  fifty(50, "Iron Intern"),
  hundred(100, "Centurion");

  final int value;
  final String name;

  const HoursMilestoneEnums(this.value, this.name);
}

class HoursMilestone extends Milestone {
  HoursMilestone(
      {required super.id,
      required super.name,
      required super.caption,
      required super.description,
      required super.rule,
      required super.target,
      required super.type});

  static List<Milestone> loadMilestones() {
    final days = HoursMilestoneEnums.values;

    return days.mapIndexed((index, hours) {
      final description =
          'Prove your dedication by logging ${hours.value} hours of training. This challenge is for the truly committed.';
      final caption = 'Train for ${hours.value} days';
      final rule = 'Log ${hours.value} days of training to complete this ${hours.value}-Hour Challenge.';
      return HoursMilestone(
          id: "Days_Milestone_${hours.value}_$index",
          name: hours.name.toUpperCase(),
          caption: caption,
          description: description,
          rule: rule,
          target: hours.value,
          type: MilestoneType.hours);
    }).toList();
  }
}

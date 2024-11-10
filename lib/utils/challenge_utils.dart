import 'package:tracker_app/enums/milestone_type_enums.dart';
import 'package:tracker_app/utils/string_utils.dart';

String challengeTargetSummary({required MilestoneType type, required num target, required}) {
  return switch (type) {
    MilestoneType.weekly => "$target ${pluralize(word: "Week", count: target.toInt())}",
    MilestoneType.reps => "${numbersInKOrM(target.toInt())} ${pluralize(word: "Rep", count: target.toInt())}",
    MilestoneType.days => "$target ${pluralize(word: "Day", count: target.toInt())}",
    MilestoneType.hours => "$target ${pluralize(word: "Hour", count: target.toInt())}",
  };
}

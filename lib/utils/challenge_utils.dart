import 'package:tracker_app/enums/challenge_type_enums.dart';
import 'package:tracker_app/utils/string_utils.dart';

import 'general_utils.dart';

String challengeTargetSummary({required ChallengeType type, required int target, required}) {
  return switch (type) {
    ChallengeType.weekly => "$target ${pluralize(word: "Week", count: target)}",
    ChallengeType.reps => "${target}k ${pluralize(word: "Rep", count: target)}",
    ChallengeType.days => "$target ${pluralize(word: weightLabel(), count: target)}",
    ChallengeType.weight => "$target ${pluralize(word: "Day", count: target)}",
  };
}

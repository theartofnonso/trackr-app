import 'package:tracker_app/enums/challenge_type_enums.dart';
import 'package:tracker_app/utils/string_utils.dart';

import 'general_utils.dart';

String challengeTargetSummary({required ChallengeType type, required num target, required}) {
  return switch (type) {
    ChallengeType.weekly => "$target ${pluralize(word: "Week", count: target.toInt())}",
    ChallengeType.reps => "${numbersInKOrM(target.toInt())} ${pluralize(word: "Rep", count: target.toInt())}",
    ChallengeType.days => "$target ${pluralize(word: "Day", count: target.toInt())}",
    ChallengeType.weight => "$target ${pluralize(word: weightLabel(), count: target.toInt())}",
  };
}

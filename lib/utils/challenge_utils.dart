
import 'package:tracker_app/enums/challenge_type_enums.dart';
import 'package:tracker_app/utils/string_utils.dart';

import 'general_utils.dart';

String challengeTargetSummary({required ChallengeType type, required int target, required}) {
  if (type == ChallengeType.weekly) {
    return "$target ${pluralize(word: "Week", count: target)}";
  }

  if (type == ChallengeType.reps) {
    return "${target}k ${pluralize(word: "Rep", count: target)}";
  }

  if (type == ChallengeType.weight) {
    return "$target ${pluralize(word: weightLabel(), count: target)}";
  }

  if (type == ChallengeType.days) {
    return "$target ${pluralize(word: "Day", count: target)}";
  }
  return "";
}
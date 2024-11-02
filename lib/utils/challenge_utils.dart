
import 'package:tracker_app/utils/string_utils.dart';

import '../dtos/streaks/challenge_template.dart';
import '../dtos/streaks/days_challenge_dto.dart';
import '../dtos/streaks/reps_challenge_dto.dart';
import '../dtos/streaks/weekly_challenge_dto.dart';
import '../dtos/streaks/weight_challenge_dto.dart';
import 'general_utils.dart';

String challengeTargetSummary({required ChallengeTemplate dto}) {
  if (dto is WeeklyChallengeDto) {
    return "${dto.target} ${pluralize(word: "Week", count: dto.target)}";
  }

  if (dto is RepsChallengeDto) {
    return "10k ${pluralize(word: "Rep", count: dto.target)}";
  }

  if (dto is WeightChallengeDto) {
    return "${dto.target} ${pluralize(word: weightLabel(), count: dto.target)}";
  }

  if (dto is DaysChallengeDto) {
    return "${dto.target} ${pluralize(word: "Day", count: dto.target)}";
  }
  return "";
}
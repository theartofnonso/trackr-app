import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../dtos/streaks/challenge_template.dart';
import '../../dtos/streaks/days/days_challenge_dto.dart';
import '../../dtos/streaks/reps/reps_challenge_dto.dart';
import '../../dtos/streaks/weight/weight_challenge_dto.dart';
import '../../dtos/streaks/weekly/weekly_challenge_dto.dart';

class ChallengeTargetIcon extends StatelessWidget {
  final ChallengeTemplate dto;

  const ChallengeTargetIcon({super.key, required this.dto});

  @override
  Widget build(BuildContext context) {
    if (dto is WeeklyChallengeDto) {
      return const FaIcon(
        FontAwesomeIcons.calendarDays,
        color: Colors.white,
        size: 12,
      );
    }

    if (dto is RepsChallengeDto) {
      return const FaIcon(
        FontAwesomeIcons.hashtag,
        color: Colors.white,
        size: 12,
      );
    }

    if (dto is WeightChallengeDto) {
      return const FaIcon(
        FontAwesomeIcons.weightHanging,
        color: Colors.white,
        size: 12,
      );
    }

    if (dto is DaysChallengeDto) {
      return const FaIcon(
        FontAwesomeIcons.calendarDay,
        color: Colors.white,
        size: 12,
      );
    }

    return const SizedBox.shrink();
  }
}
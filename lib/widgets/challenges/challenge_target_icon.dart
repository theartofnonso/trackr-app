import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tracker_app/enums/challenge_type_enums.dart';

class ChallengeTargetIcon extends StatelessWidget {
  final ChallengeType type;

  const ChallengeTargetIcon({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    if (type == ChallengeType.weekly) {
      return const FaIcon(
        FontAwesomeIcons.calendarDays,
        color: Colors.white,
        size: 12,
      );
    }

    if (type == ChallengeType.reps) {
      return const FaIcon(
        FontAwesomeIcons.hashtag,
        color: Colors.white,
        size: 12,
      );
    }

    if (type == ChallengeType.weight) {
      return const FaIcon(
        FontAwesomeIcons.weightHanging,
        color: Colors.white,
        size: 12,
      );
    }

    if (type == ChallengeType.days) {
      return const FaIcon(
        FontAwesomeIcons.calendarDay,
        color: Colors.white,
        size: 12,
      );
    }

    return const SizedBox.shrink();
  }
}

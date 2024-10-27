import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/dtos/streaks/challenge_dto.dart';
import 'package:tracker_app/repositories/challenges_repository.dart';
import 'package:tracker_app/utils/string_utils.dart';
import 'package:tracker_app/widgets/challenges/challenge_target_icon.dart';

import '../../dtos/streaks/days/days_challenge_dto.dart';
import '../../dtos/streaks/reps/reps_challenge_dto.dart';
import '../../dtos/streaks/weight/weight_challenge_dto.dart';
import '../../dtos/streaks/weekly/weekly_challenge_dto.dart';
import '../../utils/navigation_utils.dart';
import '../../widgets/information_containers/information_container_with_background_image.dart';
import 'challenge_screen.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final challenges = ChallengesRepository().loadChallenges();

    final children = challenges.map((challenge) => _ChallengeWidget(challenge: challenge)).toList();

    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                sapphireDark80,
                sapphireDark,
              ],
            ),
          ),
          child: SafeArea(
              minimum: const EdgeInsets.only(right: 10.0, bottom: 10, left: 10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                BackgroundInformationContainer(
                    image: 'images/man_woman.jpg',
                    containerColor: Colors.green.shade900,
                    content: "Power up your weekly training sessions with fun challenges that fuel your motivation.",
                    textStyle: GoogleFonts.ubuntu(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.9),
                    )),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      children: children),
                )
              ])),
        ));
  }
}

class _ChallengeWidget extends StatelessWidget {
  final Challenge challenge;

  const _ChallengeWidget({required this.challenge});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        navigateWithSlideTransition(context: context, child: ChallengeScreen(challengeDto: challenge));
      },
      child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: sapphireDark80, borderRadius: BorderRadius.circular(5)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Image.asset(
              challenge.image,
              fit: BoxFit.contain,
              height: 48, // Adjust the height as needed
            ),
            const SizedBox(height: 10),
            Text(
              challenge.name,
              style: GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            Text(
              challenge.caption,
              style: GoogleFonts.ubuntu(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white70),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            const Spacer(),
            const Divider(color: sapphireLighter, endIndent: 10),
            const SizedBox(height: 8),
            Row(children: [
              ChallengeTargetIcon(dto: challenge),
              const SizedBox(width: 8),
              Text(
                _targetSummary(dto: challenge),
                style: GoogleFonts.ubuntu(fontSize: 14, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              )
            ])
          ])),
    );
  }

  String _targetSummary({required Challenge dto}) {
    if (dto is WeeklyChallengeDto) {
      return "${dto.target} ${pluralize(word: "Week", count: dto.target)}";
    }

    if (dto is RepsChallengeDto) {
      return "10k ${pluralize(word: "Rep", count: dto.target)}";
    }

    if (dto is WeightChallengeDto) {
      return "${dto.target} ${pluralize(word: "Tonne", count: dto.target)}";
    }

    if (dto is DaysChallengeDto) {
      return "${dto.target} ${pluralize(word: "Day", count: dto.target)}";
    }
    return "";
  }
}

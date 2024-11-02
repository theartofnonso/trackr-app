import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/dtos/streaks/challenge_template.dart';
import 'package:tracker_app/repositories/challenge_templates.dart';
import 'package:tracker_app/widgets/challenges/challenge_target_icon.dart';

import '../../controllers/challenge_log_controller.dart';
import '../../utils/challenge_utils.dart';
import '../../utils/navigation_utils.dart';
import '../../widgets/information_containers/information_container_with_background_image.dart';
import 'challenge_screen.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final challenges = ChallengeTemplates().loadChallenges();

    final challengeLogController = Provider.of<ChallengeLogController>(context, listen: true);

    final children = challenges.map((challenge) {
      final activeChallenge = challengeLogController.logWhereChallengeTemplateId(id: challenge.id);

      final isActive = activeChallenge != null;
      return _ChallengeWidget(challenge: challenge, isActive: isActive);
    }).toList();

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
  final bool isActive;
  final ChallengeTemplate challenge;

  const _ChallengeWidget({required this.challenge, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        navigateWithSlideTransition(context: context, child: ChallengeScreen(challengeTemplate: challenge));
      },
      child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              gradient: isActive
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        sapphireDark80,
                        sapphireDark,
                      ],
                    )
                  : null,
              color: sapphireDark80,
              borderRadius: BorderRadius.circular(5)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Image.asset(
              "challenges_icons/green_blob.png",
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
            Divider(color: isActive ? vibrantGreen.withOpacity(0.2) : sapphireLighter, endIndent: 10),
            const SizedBox(height: 8),
            Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
              ChallengeTargetIcon(dto: challenge),
              const SizedBox(width: 8),
              Text(
                challengeTargetSummary(dto: challenge),
                style: GoogleFonts.ubuntu(fontSize: 14, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              )
            ])
          ])),
    );
  }
}

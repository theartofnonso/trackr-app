import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/dtos/appsync/challenge_log_dto.dart';

import '../../utils/challenge_utils.dart';
import '../../utils/navigation_utils.dart';
import '../../widgets/challenges/challenge_target_icon.dart';
import '../../widgets/information_containers/information_container_with_background_image.dart';
import '../no_list_empty_state.dart';
import 'active_challenge_screen.dart';

class ActiveChallengesScreen extends StatelessWidget {

  final List<ChallengeLogDto> challenges;
  
  const ActiveChallengesScreen({super.key, required this.challenges});

  @override
  Widget build(BuildContext context) {
    
    final children = challenges.map((challenge) => _ActiveChallengeWidget(challenge: challenge)).toList();

    if (children.isEmpty) {
      return const NoListEmptyState(
          icon: FaIcon(
            FontAwesomeIcons.trophy,
            color: Colors.white12,
            size: 48,
          ),
          message: "It might feel quiet now, but your active challenges will soon appear here.");
    }

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

class _ActiveChallengeWidget extends StatelessWidget {
  final ChallengeLogDto challenge;

  const _ActiveChallengeWidget({required this.challenge});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        navigateWithSlideTransition(context: context, child: ActiveChallengeScreen(log: challenge));
      },
      child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  sapphireDark80,
                  sapphireDark,
                ],
              ),
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
            Divider(color: vibrantGreen.withOpacity(0.2), endIndent: 10),
            const SizedBox(height: 8),
            Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
              ChallengeTargetIcon(type: challenge.type),
              const SizedBox(width: 8),
              Text(
                challengeTargetSummary(target: challenge.progress, type: challenge.type),
                style: GoogleFonts.ubuntu(fontSize: 14, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              )
            ])
          ])),
    );
  }
}

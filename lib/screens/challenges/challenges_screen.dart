import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/dtos/streaks/challenge_dto.dart';
import 'package:tracker_app/dtos/streaks/reps/arms_reps_challenge_dto.dart';
import 'package:tracker_app/dtos/streaks/weekly/obsessed_challenge_dto.dart';
import 'package:tracker_app/dtos/streaks/weekly/weekend_warrior_challenge_dto.dart';
import 'package:tracker_app/utils/string_utils.dart';
import 'package:tracker_app/widgets/challenges/challenge_target_icon.dart';

import '../../dtos/streaks/days/days_challenge_dto.dart';
import '../../dtos/streaks/days/hundred_days_challenge_dto.dart';
import '../../dtos/streaks/reps/reps_challenge_dto.dart';
import '../../dtos/streaks/volume/volume_challenge_dto.dart';
import '../../dtos/streaks/weekly/never_miss_a_leg_day_challenge_dto.dart';
import '../../dtos/streaks/weekly/never_miss_a_monday_challenge_dto.dart';
import '../../dtos/streaks/weekly/weekly_challenge_dto.dart';
import '../../utils/navigation_utils.dart';
import '../../widgets/information_containers/information_container_with_background_image.dart';
import 'challenge_screen.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final legDayChallenge = NeverMissALegDayChallengeDto(
      id: '1',
      name: 'Never Miss A Leg Day',
      description:
          'Commit to your fitness goals by never skipping leg day. Strengthen your lower body through consistent training, enhancing your overall physique and performance.',
      caption: "Complete leg workouts consistently.",
      target: 16,
      // Consistent with the rule
      rule: "Log at least one leg-focused training session every week for 16 consecutive weeks.",
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 112)),
      // 16 weeks
      isCompleted: false,
      image: 'challenges_icons/green_blob.png',
    );

    // Instance of "Never Miss A Monday" Challenge
    final mondayChallenge = NeverMissAMondayChallengeDto(
      id: '2',
      name: 'Never Miss A Monday',
      description:
          'Kickstart your week with energy and dedication. Commit to a Monday workout to set a positive tone for the days ahead, ensuring consistent progress towards your fitness goals.',
      caption: "Train every Monday.",
      target: 16,
      // Consistent with the rule
      rule: "Log at least one training session every Monday for 16 consecutive weeks.",
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 112)),
      // 16 weeks
      isCompleted: false,
      image: 'challenges_icons/green_blob.png',
    );

    // Instance of "Weekend Warrior" Challenge
    final weekendChallenge = WeekendWarriorChallengeDto(
      id: '3',
      name: 'Weekend Warrior',
      description:
          'Maximize your weekends by dedicating time to intense training sessions. Push your limits and achieve significant fitness milestones by committing to workouts every weekend.',
      caption: "Train every weekend.",
      target: 16,
      // Consistent with the rule
      rule: "Log at least one training session every weekend (Saturday or Sunday) for 16 consecutive weeks.",
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 112)),
      // 16 weeks
      isCompleted: false,
      image: 'challenges_icons/green_blob.png',
    );

    // Instance of "Weekend Warrior" Challenge
    final obsessedChallenge = ObsessedChallengeDto(
      id: '4',
      name: 'Obsessed',
      description:
          'Embrace your fitness journey with relentless dedication. Commit to consistent training by never missing a single week for six months.',
      caption: "Train every week without fail.",
      target: 26,
      // 26 weeks for 6 months
      rule: "Log at least one training session every week for 26 consecutive weeks without missing a single week.",
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 182)),
      // 16 weeks
      isCompleted: false,
      image: 'challenges_icons/green_blob.png',
    );

    final armsChallenge = ArmsRepsChallengeDto(
      id: '5',
      name: '10K Reps - Arms',
      description:
      'Embrace your fitness journey with relentless dedication. Commit to consistent training by never missing a single week for six months.',
      caption: "Train every week without fail.",
      target: 10000,
      // 26 weeks for 6 months
      rule: "Log at least one training session every week for 26 consecutive weeks without missing a single week.",
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 182)),
      // 16 weeks
      isCompleted: false,
      image: 'challenges_icons/green_blob.png',
    );

    final hundredDaysChallenge = HundredDaysChallengeDto(
      id: '6',
      name: '10K Reps - Arms',
      description:
      'Embrace your fitness journey with relentless dedication. Commit to consistent training by never missing a single week for six months.',
      caption: "Train every week without fail.",
      target: 100,
      // 26 weeks for 6 months
      rule: "Log at least one training session every week for 26 consecutive weeks without missing a single week.",
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 182)),
      // 16 weeks
      isCompleted: false,
      image: 'challenges_icons/green_blob.png',
    );

    final challenges = [legDayChallenge, armsChallenge, mondayChallenge, hundredDaysChallenge, weekendChallenge, obsessedChallenge];

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
            Text(
              challenge.name,
              style: GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            const Spacer(),
            Text(
              challenge.description,
              style: GoogleFonts.ubuntu(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white70),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            const SizedBox(height: 8),
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

    if (dto is VolumeChallengeDto) {
      return "${dto.target} ${pluralize(word: "Tonne", count: dto.target)}";
    }

    if (dto is DaysChallengeDto) {
      return "${dto.target} ${pluralize(word: "Day", count: dto.target)}";
    }
    return "";
  }
}

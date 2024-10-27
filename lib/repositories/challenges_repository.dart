
import 'package:tracker_app/dtos/streaks/challenge_dto.dart';
import 'package:tracker_app/dtos/streaks/reps/reps_challenge_dto.dart';
import 'package:tracker_app/dtos/streaks/weekly/weekly_challenge_dto.dart';

import '../dtos/streaks/weekly/obsessed_challenge_dto.dart';
import '../dtos/streaks/weight/weight_challenge_dto.dart';

class ChallengesRepository {

  /// Weekly Challenges
  final _legDayChallenge = WeeklyChallengeDto(
    id: 'NMALDC_001',
    name: 'Never Miss A Leg Day'.toUpperCase(),
    description:
    'Commit to your fitness goals by never skipping leg day. Strengthen your lower body through consistent training, enhancing your overall physique and performance.',
    caption: "Train legs weekly",
    target: 16,
    rule: "Log at least one leg-focused training session every week for 16 consecutive weeks.",
    startDate: DateTime.now(),
    endDate: DateTime.now().add(const Duration(days: 112)),
    isCompleted: false,
    image: 'challenges_icons/green_blob.png',
  );
  final _mondayChallenge = WeeklyChallengeDto(
    id: 'NMAMC_002',
    name: 'Never Miss A Monday'.toUpperCase(),
    description:
    'Kickstart your week with energy and dedication. Commit to a Monday workout to set a positive tone for the days ahead, ensuring consistent progress towards your fitness goals.',
    caption: "Train every Monday",
    target: 16,
    rule: "Log at least one training session every Monday for 16 consecutive weeks.",
    startDate: DateTime.now(),
    endDate: DateTime.now().add(const Duration(days: 112)),
    isCompleted: false,
    image: 'challenges_icons/green_blob.png',
  );
  final _weekendChallenge = WeeklyChallengeDto(
    id: 'WWC_003',
    name: 'Weekend Warrior'.toUpperCase(),
    description:
    'Maximize your weekends by dedicating time to intense training sessions. Push your limits and achieve significant fitness milestones by committing to workouts every weekend.',
    caption: "Train every weekend",
    target: 16,
    rule: "Log at least one training session every weekend (Saturday or Sunday) for 16 consecutive weeks.",
    startDate: DateTime.now(),
    endDate: DateTime.now().add(const Duration(days: 112)),
    isCompleted: false,
    image: 'challenges_icons/green_blob.png',
  );

  /// Reps Challenges
  final _repsChallenge = RepsChallengeDto(
    id: 'RP_000',
    name: 'Reps Mastery'.toUpperCase(),
    description:
    'Focus on building strength and endurance in your chosen muscle group by committing to a high-rep challenge. Consistency and dedication will be key as you target your goals each week.',
    caption: "Accumulate 10k reps",
    target: 10000, // 26 weeks for 6 months
    rule: "Log at least one high-rep training session targeting your selected muscle group every training session. Achieve your weekly reps goal without missing a single week.",
    startDate: DateTime.now(),
    endDate: DateTime.now().add(const Duration(days: 182)), // 26 weeks
    isCompleted: false,
    image: 'challenges_icons/green_blob.png',
  );

  /// Weight Challenges
  final _weightChallenge = WeightChallengeDto(
    id: 'WHT_000',
    name: 'Twice as strong'.toUpperCase(),
    description:
    'Challenge yourself to lift progressively heavier weights each week. Aim to meet your weight target by staying consistent and focused on your selected muscle group. This challenge is designed to boost your strength and endurance as you push your limits each session.',
    caption: "Hit your personal best",
    target: 0, // Total weight target in kg or lbs for 26 weeks
    rule: "Log your weights lifted each session and work towards meeting your weekly weight goal in your chosen muscle group. Consistently meet your weekly target without missing a week to complete the challenge.",
    startDate: DateTime.now(),
    endDate: DateTime.now().add(const Duration(days: 182)), // 26 weeks
    isCompleted: false,
    image: 'challenges_icons/green_blob.png',
  );

  /// Days Challenges
  final _thirtyDaysChallenge = ObsessedChallengeDto(
    id: 'OBC_30_001',
    name: 'Newbie Gains'.toUpperCase(),
    description:
    'Start your journey by logging 30 days. Perfect for those beginning their obsession with fitness.',
    caption: 'Train for 30 days',
    target: 30,
    rule:
    'Log at least one training session every day for 30 consecutive days to complete the 30-Day Obsessed Challenge.',
    startDate: DateTime.now(),
    endDate: DateTime.now().add(const Duration(days: 30)),
    isCompleted: false,
    image: 'challenges_icons/green_blob.png',
  );
  final _fiftyDaysChallenge = ObsessedChallengeDto(
    id: 'OBC_50_002',
    name: 'Gym Bro'.toUpperCase(),
    description:
    'Take your commitment to the next level by logging 50 days of training.',
    caption: 'Train for 50 days',
    target: 50,
    rule:
    'Log at least one training session every day for 50 consecutive days to complete the 50-Day Obsessed Challenge.',
    startDate: DateTime.now(),
    endDate: DateTime.now().add(const Duration(days: 50)),
    isCompleted: false,
    image: 'challenges_icons/green_blob.png',
  );
  final _hundredDaysChallenge = ObsessedChallengeDto(
    id: 'OBC_100_003',
    name: 'Gandalf The Buff'.toUpperCase(),
    description:
    'Prove your dedication by logging 100 days of training. This challenge is for the truly committed.',
    caption: 'Train for 100 days',
    target: 100,
    rule:
    'Log at least one training session every day for 100 consecutive days to complete the 100-Day Obsessed Challenge.',
    startDate: DateTime.now(),
    endDate: DateTime.now().add(const Duration(days: 100)),
    isCompleted: false,
    image: 'challenges_icons/green_blob.png',
  );


  List<Challenge> loadChallenges() {
    final challenges = <Challenge>[];

    /// Add Weekly Challenges
    challenges.add(_legDayChallenge);
    challenges.add(_mondayChallenge);
    challenges.add(_weekendChallenge);

    /// Add Reps Challenges
    challenges.add(_repsChallenge);

    /// Add Weight Challenges
    challenges.add(_weightChallenge);

    /// Add Days Challenges
    challenges.add(_thirtyDaysChallenge);
    challenges.add(_fiftyDaysChallenge);
    challenges.add(_hundredDaysChallenge);

    return challenges;

  }
}

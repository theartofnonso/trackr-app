import 'package:tracker_app/dtos/challengeTemplates/challenge_template.dart';
import 'package:tracker_app/dtos/challengeTemplates/days_challenge_dto.dart';
import 'package:tracker_app/dtos/challengeTemplates/reps_challenge_dto.dart';
import 'package:tracker_app/dtos/challengeTemplates/weekly_challenge_dto.dart';
import 'package:tracker_app/enums/challenge_type_enums.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';

import '../dtos/challengeTemplates/weight_challenge_dto.dart';

class ChallengeTemplates {
  /// Weekly Challenges
  final _legDayChallenge = WeeklyChallengeTemplate(
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
      type: ChallengeType.weekly);

  final _mondayChallenge = WeeklyChallengeTemplate(
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
      type: ChallengeType.weekly);

  final _weekendChallenge = WeeklyChallengeTemplate(
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
      type: ChallengeType.weekly);

  /// Reps Challenges
  final _repsChallenge = RepsChallengeTemplate(
      id: 'RP_000',
      name: '10K Reps Marathon'.toUpperCase(),
      description:
          'Focus on building strength and endurance in your chosen muscle group by committing to this challenge. Consistency and dedication will be key as you target your goals each week.',
      caption: "Accumulate 10k reps",
      target: 10000,
      muscleGroup: MuscleGroup.none,
      // 26 weeks for 6 months
      rule: "Accumulate reps targeting your selected muscle group in every training session.",
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 182)),
      // 26 weeks
      isCompleted: false,
      type: ChallengeType.reps);

  /// Weight Challenges
  final _weightChallenge = WeightChallengeTemplate(
      id: 'WHT_000',
      name: 'Twice as strong'.toUpperCase(),
      description:
          'Challenge yourself to lift progressively heavier weights each week. Aim to meet your weight target by staying consistent and focused on your selected exercise.',
      caption: "Hit your personal best",
      target: 0,
      // Total weight target in kg or lbs for 26 weeks
      rule: "Train each session and work towards meeting your weight goal in your chosen exercise.",
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 182)),
      // 26 weeks
      isCompleted: false,
      type: ChallengeType.weight, exercise: null);

  /// Days Challenges
  final _thirtyDaysChallenge = DaysChallengeTemplate(
      id: 'DYS_30_001',
      name: '30 Days of Gains'.toUpperCase(),
      description: 'Start your journey by logging 30 days. Perfect for those beginning their obsession with fitness.',
      caption: 'Train for 30 days',
      target: 30,
      rule: 'Log 30 days of training to complete this 30-Day Challenge.',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 30)),
      isCompleted: false,
      type: ChallengeType.days);
  final _fiftyDaysChallenge = DaysChallengeTemplate(
      id: 'DYC_50_002',
      name: '50 Days of Gains'.toUpperCase(),
      description: 'Take your commitment to the next level by logging 50 days of training.',
      caption: 'Train for 50 days',
      target: 50,
      rule: 'Log 50 days of training to complete this 50-Day Challenge.',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 50)),
      isCompleted: false,
      type: ChallengeType.days);

  final _hundredDaysChallenge = DaysChallengeTemplate(
      id: 'DYS_100_003',
      name: '100 Days of Gains'.toUpperCase(),
      description: 'Prove your dedication by logging 100 days of training. This challenge is for the truly committed.',
      caption: 'Train for 100 days',
      target: 100,
      rule: 'Log 100 days of training to complete this 100-Day Challenge.',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 100)),
      isCompleted: false,
      type: ChallengeType.days);

  List<ChallengeTemplate> loadTemplates() {
    final templates = <ChallengeTemplate>[];

    /// Add Weekly Challenges
    templates.add(_legDayChallenge);
    templates.add(_mondayChallenge);
    templates.add(_weekendChallenge);

    /// Add Reps Challenges
    templates.add(_repsChallenge);

    /// Add Weight Challenges
    templates.add(_weightChallenge);

    /// Add Days Challenges
    templates.add(_thirtyDaysChallenge);
    templates.add(_fiftyDaysChallenge);
    templates.add(_hundredDaysChallenge);

    return templates;
  }
}

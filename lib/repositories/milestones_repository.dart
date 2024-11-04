import 'package:tracker_app/dtos/challengeTemplates/milestone_dto.dart';
import 'package:tracker_app/dtos/challengeTemplates/days_challenge_dto.dart';
import 'package:tracker_app/dtos/challengeTemplates/reps_marathon_milestone.dart';
import 'package:tracker_app/dtos/challengeTemplates/weekly_challenge_dto.dart';
import 'package:tracker_app/enums/milestone_type_enums.dart';
class MilestonesRepository {
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
      type: MilestoneType.weekly);

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
      type: MilestoneType.weekly);

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
      type: MilestoneType.weekly);

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
      type: MilestoneType.days);
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
      type: MilestoneType.days);

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
      type: MilestoneType.days);

  List<Milestone> loadMilestones() {
    final milestones = <Milestone>[];

    /// Add Weekly Challenges
    milestones.add(_legDayChallenge);
    milestones.add(_mondayChallenge);
    milestones.add(_weekendChallenge);

    /// Add Days Challenges
    milestones.add(_thirtyDaysChallenge);
    milestones.add(_fiftyDaysChallenge);
    milestones.add(_hundredDaysChallenge);

    /// Add Reps Marathon Milestones
    final repsMilestones = RepsMarathonMilestone.loadMilestones();
    for (final milestone in repsMilestones) {
      milestones.add(milestone);
    }

    return milestones;
  }
}

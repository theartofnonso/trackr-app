import 'package:tracker_app/dtos/challengeTemplates/milestone_dto.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';

import '../../enums/milestone_type_enums.dart';

class WeeklyMilestone extends Milestone {
  final MuscleGroupFamily muscleGroupFamily;

  WeeklyMilestone(
      {required super.id,
      required super.name,
      required super.caption,
      required super.description,
      required super.rule,
      required super.target,
      this.muscleGroupFamily = MuscleGroupFamily.none,
      required super.type});

  static List<Milestone> loadMilestones() {
    final mondayMilestone = WeeklyMilestone(
        id: 'NMAMC_002',
        name: 'Never Miss A Monday'.toUpperCase(),
        description:
            'Kickstart your week with energy and dedication. Commit to a Monday workout to set a positive tone for the days ahead, ensuring consistent progress towards your fitness goals.',
        caption: "Train every Monday",
        target: 16,
        rule: "Log at least one training session every Monday for 16 consecutive weeks.",
        type: MilestoneType.weekly);

    final weekendMilestone = WeeklyMilestone(
        id: 'WWC_003',
        name: 'Weekend Warrior'.toUpperCase(),
        description:
            'Maximize your weekends by dedicating time to intense training sessions. Push your limits and achieve significant fitness milestones by committing to workouts every weekend.',
        caption: "Train every weekend",
        target: 16,
        rule: "Log at least one training session every weekend (Saturday or Sunday) for 16 consecutive weeks.",
        type: MilestoneType.weekly);

    final legDayMilestone = WeeklyMilestone(
        id: 'NMALDC_001',
        name: 'Never Miss A Leg Day'.toUpperCase(),
        description:
            'Commit to your fitness goals by never skipping leg day. Strengthen your lower body through consistent training, enhancing your overall physique and performance.',
        caption: "Train legs weekly",
        target: 16,
        muscleGroupFamily: MuscleGroupFamily.legs,
        rule: "Log at least one leg-focused training session every week for 16 consecutive weeks.",
        type: MilestoneType.weekly);

    return [mondayMilestone, weekendMilestone, legDayMilestone];
  }
}

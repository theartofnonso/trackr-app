import 'package:tracker_app/dtos/challengeTemplates/milestone_dto.dart';
import 'package:tracker_app/dtos/challengeTemplates/days_milestone_dto.dart';
import 'package:tracker_app/dtos/challengeTemplates/reps_marathon_milestone.dart';
import 'package:tracker_app/dtos/challengeTemplates/weekly_milestone_dto.dart';
class MilestonesRepository {

  List<Milestone> loadMilestones() {
    final milestones = <Milestone>[];

    /// Add Weekly Challenges
    final weeklyMilestones = WeeklyMilestone.loadMilestones();
    for (final milestone in weeklyMilestones) {
      milestones.add(milestone);
    }

    /// Add Days Challenges
    final daysMilestones = DaysMilestone.loadMilestones();
    for (final milestone in daysMilestones) {
      milestones.add(milestone);
    }

    /// Add Reps Marathon Milestones
    final repsMilestones = RepsMarathonMilestone.loadMilestones();
    for (final milestone in repsMilestones) {
      milestones.add(milestone);
    }

    return milestones;
  }
}

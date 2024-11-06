import 'package:tracker_app/dtos/milestones/milestone_dto.dart';
import 'package:tracker_app/dtos/milestones/days_milestone_dto.dart';
import 'package:tracker_app/dtos/milestones/reps_milestone.dart';
import 'package:tracker_app/dtos/milestones/weekly_milestone_dto.dart';

import '../dtos/appsync/routine_log_dto.dart';
import '../dtos/milestones/hours_milestone_dto.dart';
class MilestonesRepository {

  List<Milestone> loadMilestones({required List<RoutineLogDto> logs}) {
    final milestones = <Milestone>[];

    /// Add Weekly Challenges
    final weeklyMilestones = WeeklyMilestone.loadMilestones(logs: logs);
    for (final milestone in weeklyMilestones) {
      milestones.add(milestone);
      print("here");
    }

    /// Add Days Challenges
    final daysMilestones = DaysMilestone.loadMilestones(logs: logs);
    for (final milestone in daysMilestones) {
      milestones.add(milestone);
    }

    /// Add Reps Milestones
    final repsMilestones = RepsMilestone.loadMilestones(logs: logs);
    for (final milestone in repsMilestones) {
      milestones.add(milestone);
    }

    /// Add Hours Milestones
    final hoursMilestones = HoursMilestone.loadMilestones(logs: logs);
    for (final milestone in hoursMilestones) {
      milestones.add(milestone);
    }

    milestones.sort((a, b) => a.name.compareTo(b.name));

    return milestones;
  }
}

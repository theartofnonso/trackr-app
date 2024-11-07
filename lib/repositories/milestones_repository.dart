import 'dart:collection';

import 'package:tracker_app/dtos/milestones/milestone_dto.dart';
import 'package:tracker_app/dtos/milestones/days_milestone_dto.dart';
import 'package:tracker_app/dtos/milestones/reps_milestone.dart';
import 'package:tracker_app/dtos/milestones/weekly_milestone_dto.dart';

import '../dtos/appsync/routine_log_dto.dart';
import '../dtos/milestones/hours_milestone_dto.dart';
class MilestonesRepository {

  final List<Milestone> _milestones = [];

  UnmodifiableListView<Milestone> get milestones => UnmodifiableListView(_milestones);

  void loadMilestones({required List<RoutineLogDto> logs}) {

    /// Add Weekly Challenges
    final weeklyMilestones = WeeklyMilestone.loadMilestones(logs: logs);
    for (final milestone in weeklyMilestones) {
      _milestones.add(milestone);
    }

    /// Add Days Challenges
    final daysMilestones = DaysMilestone.loadMilestones(logs: logs);
    for (final milestone in daysMilestones) {
      _milestones.add(milestone);
    }

    /// Add Reps Milestones
    final repsMilestones = RepsMilestone.loadMilestones(logs: logs);
    for (final milestone in repsMilestones) {
      _milestones.add(milestone);
    }

    /// Add Hours Milestones
    final hoursMilestones = HoursMilestone.loadMilestones(logs: logs);
    for (final milestone in hoursMilestones) {
      _milestones.add(milestone);
    }

    _milestones.sort((a, b) => a.name.compareTo(b.name));

  }

  List<Milestone> fetchMilestones({required List<RoutineLogDto> logs}) {

    List<Milestone> milestones = [];

    /// Add Weekly Challenges
    final weeklyMilestones = WeeklyMilestone.loadMilestones(logs: logs);
    for (final milestone in weeklyMilestones) {
      milestones.add(milestone);
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

  List<Milestone> wherePending() => _milestones.where((milestone) => milestone.progress.$1 < 1).toList();

  List<Milestone> whereCompleted() => milestones.where((milestone) => milestone.progress.$1 == 1).toList();

  void clear() {
    _milestones.clear();
  }
}

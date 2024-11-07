import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/milestones/milestone_dto.dart';
import 'package:tracker_app/repositories/milestones_repository.dart';

import '../dtos/appsync/routine_log_dto.dart';

class MilestoneController extends ChangeNotifier {

  late MilestonesRepository _milestonesRepository;

  MilestoneController(MilestonesRepository milestonesRepository) {
    _milestonesRepository = milestonesRepository;
  }

  List<Milestone> get milestones => _milestonesRepository.milestones;

  void loadMilestones({required List<RoutineLogDto> logs}) {
    _milestonesRepository.loadMilestones(logs: logs);
  }

  List<Milestone> fetchMilestones({required List<RoutineLogDto> logs}) {
    return _milestonesRepository.fetchMilestones(logs: logs);
  }

  List<Milestone> pendingMilestones() => _milestonesRepository.wherePending();

  List<Milestone> completedMilestones() => _milestonesRepository.whereCompleted();

  void clear() {
    _milestonesRepository.clear();
  }
}

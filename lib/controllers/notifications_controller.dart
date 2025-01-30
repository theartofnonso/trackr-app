import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/appsync/activity_log_dto.dart';
import '../dtos/appsync/routine_log_dto.dart';
import '../dtos/appsync/routine_template_dto.dart';

class NotificationsController extends ChangeNotifier {

  bool _hasNoLoggedActivities = true;

  bool _hasNoLoggedRoutines = true;

  bool _hasNoRoutineTemplates = true;

  bool get hasNoLoggedActivities => _hasNoLoggedActivities;

  bool get hasNoLoggedRoutines => _hasNoLoggedRoutines;

  bool get hasNoRoutineTemplates => _hasNoRoutineTemplates;

  void checkHasNoLoggedActivities({required List<ActivityLogDto> activities}) {
    _hasNoLoggedActivities = activities.isEmpty;
    notifyListeners();
  }

  void checkHasNoLoggedRoutines({required List<RoutineLogDto> logs}) {
    _hasNoLoggedRoutines = logs.isEmpty;
    notifyListeners();
  }

  void checkHasNoRoutineTemplates({required List<RoutineTemplateDto> templates}) {
    _hasNoRoutineTemplates = templates.isEmpty;
    notifyListeners();
  }

  void notify() {
    notifyListeners();
  }

}
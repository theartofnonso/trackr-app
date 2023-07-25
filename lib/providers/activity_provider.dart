import 'package:flutter/material.dart';
import 'package:tracker_app/utils/datetime_utils.dart';

extension ActivityExtension on Activity {
  
  List<ActivityDuration> historyWhere({required DateTimeRange range}) {
    return history.where((timePeriod) => timePeriod.start.isBetweenRange(range: range)).toList();
  }
}

extension ActivityDurationExtension on ActivityDuration {
  Duration duration() {
    return end.difference(start);
  }
}

class Activity {
  final String id;
  final String name;
  final List<ActivityDuration> history;
  final String description;

  Activity({required this.id, required this.name, required this.history, required this.description});

}
class ActivityDuration {
  final String id;
  final String activityId;
  final DateTime start;
  final DateTime end;
  final String description;

  ActivityDuration(
      {required this.activityId, required this.start, required this.end, required this.description,})
      : id = "id_duration_$activityId";
}

class ActivityProvider extends ChangeNotifier {

  List<Activity> _activities = [];

  List<Activity> get activities {
    return [..._activities];
  }

  void listActivities() {
  }

  Activity addNewActivity({required String name}) {
    final activityToAdd = Activity(
        id: "id_${DateTime.now().millisecond}",
        name: name,
        history: [
          ActivityDuration(
              start: DateTime.now().subtract(const Duration(days: 5, hours: 5)),
              end: DateTime.now().subtract(const Duration(days: 5, hours: 2)),
              activityId: name, description: ''),
          ActivityDuration(
              start: DateTime.now().subtract(const Duration(days: 4, hours: 4)),
              end: DateTime.now().subtract(const Duration(days: 4, hours: 3)),
              activityId: name, description: ''),
          ActivityDuration(
              start: DateTime.now().subtract(const Duration(days: 3, hours: 3)),
              end: DateTime.now().subtract(const Duration(days: 3, hours: 1)),
              activityId: name, description: ''),
          ActivityDuration(
              start: DateTime.now().subtract(const Duration(days: 2, hours: 2)),
              end: DateTime.now().subtract(const Duration(days: 2, hours: 1)),
              activityId: name, description: ''),
          ActivityDuration(
              start: DateTime.now().subtract(const Duration(days: 1, hours: 10)),
              end: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
              activityId: name, description: ''),
          ActivityDuration(
              start: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
              end: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
              activityId: name, description: "")
        ],
        description: "A note");
    _activities.add(activityToAdd);
    notifyListeners();
    return activityToAdd;
  }

  void editNewActivity({required Activity oldActivity, required String activityLabel}) {
    final newActivity = Activity(
        id: oldActivity.id,
        name: activityLabel,
        history: [
          ActivityDuration(
              start:
              DateTime.now().subtract(const Duration(days: 5, hours: 5)),
              end: DateTime.now().subtract(const Duration(days: 5, hours: 2)),
              activityId: activityLabel, description: ''),
          ActivityDuration(
              start:
              DateTime.now().subtract(const Duration(days: 4, hours: 4)),
              end: DateTime.now().subtract(const Duration(days: 4, hours: 3)),
              activityId: activityLabel, description: ''),
          ActivityDuration(
              start:
              DateTime.now().subtract(const Duration(days: 3, hours: 3)),
              end: DateTime.now().subtract(const Duration(days: 3, hours: 1)),
              activityId: activityLabel, description: ''),
          ActivityDuration(
              start:
              DateTime.now().subtract(const Duration(days: 2, hours: 2)),
              end: DateTime.now().subtract(const Duration(days: 2, hours: 1)),
              activityId: activityLabel, description: '')
        ],
        description: "A note");
    final activityToUpdate = _activities.firstWhere((activity) => activity.id == oldActivity.id);
    _activities = _activities.map((activity) => activity.id == activityToUpdate.id ? newActivity : activity).toList();
    notifyListeners();
  }

  void removeActivity({required Activity activityToRemove}) {
    _activities.removeWhere((activity) => activity.id == activityToRemove.id);
    notifyListeners();
  }
}

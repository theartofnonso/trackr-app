import 'package:flutter/material.dart';

extension ActivityExtension on Activity{

  List<Duration> durations() {
    return history.map((timePeriod) => timePeriod.end.difference(timePeriod.start)).toList();
  }

}

extension ActivityDurationExtension on ActivityDuration{

  Duration duration() {
    return end.difference(start);
  }

}

class Activity {
  final String id;
  final String label;
  final List<ActivityDuration> history;
  final String notes;

  Activity({required this.label, required this.history, required this.notes})
      : id = "id_$label";
}

class ActivityDuration {
  final String id;
  final String activityId;
  final DateTime start;
  final DateTime end;

  ActivityDuration(
      {required this.activityId, required this.start, required this.end})
      : id = "id_duration_$activityId";
}

class ActivityProvider extends ChangeNotifier {
  List<Activity> _activities = [];

  List<Activity> get activities {
    return [..._activities];
  }

  void listActivities() {
    _activities = [
      Activity(
          label: "Sleeping",
          history: [
            ActivityDuration(
                start: DateTime.now().subtract(const Duration(days: 5, hours: 5)),
                end: DateTime.now().subtract(const Duration(days: 5, hours: 1)),
                activityId: 'Sleeping'),
            ActivityDuration(
                start: DateTime.now().subtract(const Duration(days: 4, hours: 8)),
                end: DateTime.now().subtract(const Duration(days: 4, hours: 1)),
                activityId: 'Sleeping'),
            ActivityDuration(
                start: DateTime.now().subtract(const Duration(days: 3, hours: 6)),
                end: DateTime.now().subtract(const Duration(days: 3, hours: 1)),
                activityId: 'Sleeping'),
            ActivityDuration(
                start: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
                end: DateTime.now().subtract(const Duration(days: 2, hours: 1)),
                activityId: 'Sleeping')
          ],
          notes: "A note"),
      Activity(
          label: "Gyming",
          history: [
            ActivityDuration(
                start: DateTime.now().subtract(const Duration(days: 5, hours: 5)),
                end: DateTime.now().subtract(const Duration(days: 5, hours: 1)),
                activityId: 'Gyming'),
            ActivityDuration(
                start: DateTime.now().subtract(const Duration(days: 4, hours: 4)),
                end: DateTime.now().subtract(const Duration(days: 4, hours: 1)),
                activityId: 'Gyming'),
            ActivityDuration(
                start: DateTime.now().subtract(const Duration(days: 3, hours: 3)),
                end: DateTime.now().subtract(const Duration(days: 3, hours: 1)),
                activityId: 'Gyming'),
            ActivityDuration(
                start: DateTime.now().subtract(const Duration(days: 2, hours: 2)),
                end: DateTime.now().subtract(const Duration(days: 2, hours: 1)),
                activityId: 'Gyming')
          ],
          notes: "A note"),
      Activity(
          label: "Walking",
          history: [
            ActivityDuration(
                start: DateTime.now().subtract(const Duration(days: 5, hours: 6)),
                end: DateTime.now().subtract(const Duration(days: 5, hours: 2)),
                activityId: 'Walking'),
            ActivityDuration(
                start: DateTime.now().subtract(const Duration(days: 4, hours: 7)),
                end: DateTime.now().subtract(const Duration(days: 4, hours: 6)),
                activityId: 'Walking'),
            ActivityDuration(
                start: DateTime.now().subtract(const Duration(days: 3, hours: 3)),
                end: DateTime.now().subtract(const Duration(days: 3, hours: 2)),
                activityId: 'Walking'),
            ActivityDuration(
                start: DateTime.now().subtract(const Duration(days: 2, hours: 2)),
                end: DateTime.now().subtract(const Duration(days: 2, hours: 1)),
                activityId: 'Walking')
          ],
          notes: "A note"),
      Activity(
          label: "Reading",
          history: [
            ActivityDuration(
                start: DateTime.now().subtract(const Duration(days: 5, hours: 5)),
                end: DateTime.now().subtract(const Duration(days: 5, hours: 2)),
                activityId: 'Reading'),
            ActivityDuration(
                start: DateTime.now().subtract(const Duration(days: 4, hours: 4)),
                end: DateTime.now().subtract(const Duration(days: 4, hours: 3)),
                activityId: 'Reading'),
            ActivityDuration(
                start: DateTime.now().subtract(const Duration(days: 3, hours: 3)),
                end: DateTime.now().subtract(const Duration(days: 3, hours: 1)),
                activityId: 'Reading'),
            ActivityDuration(
                start: DateTime.now().subtract(const Duration(days: 2, hours: 2)),
                end: DateTime.now().subtract(const Duration(days: 2, hours: 1)),
                activityId: 'Reading')
          ],
          notes: "A note")
    ];
  }
}

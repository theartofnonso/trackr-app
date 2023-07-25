
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/models/ModelProvider.dart';

class ActivityProvider extends ChangeNotifier {
  List<Activity> _activities = [];

  List<Activity> get activities {
    return [..._activities];
  }

  void listActivities() async {
    _activities = await Amplify.DataStore.query(Activity.classType);
    notifyListeners();
  }

  Future<List<ActivityDuration>> listActivityDurationsWhere({required String activityId}) async {
    return await Amplify.DataStore.query(
      ActivityDuration.classType,
      where: ActivityDuration.ACTIVITY.eq(activityId),
    );
  }

  Future<Activity> addActivity({required String name}) async {
    final activityToCreate = Activity(name: name);
    await Amplify.DataStore.save(activityToCreate);
    _activities.add(activityToCreate);
    notifyListeners();
    return activityToCreate;
  }

  Future<Activity> editNewActivity(
      {required Activity oldActivity, required String newActivityName}) async {
    final activityToUpdate = oldActivity.copyWith(name: newActivityName);
    await Amplify.DataStore.save(activityToUpdate,
        where: Activity.ID.eq(activityToUpdate.id));
    _activities = _activities
        .map((activity) =>
            activity.id == activityToUpdate.id ? activityToUpdate : activity)
        .toList();
    notifyListeners();

    return activityToUpdate;
  }

  Future<Activity> removeActivity({required Activity activity}) async {
    await Amplify.DataStore.delete(activity);
    _activities.removeWhere((activity) => activity.id == activity.id);
    notifyListeners();
    return activity;
  }

  Future<void> addActivityDuration(
      {required String activityId,
      required DateTime startTime,
      required DateTime endTime}) async {

    final activity = _activities.firstWhere((activity) => activity.id == activityId);

    final activityDuration = ActivityDuration(
        activity: activity,
        startTime: TemporalDateTime.fromString("${startTime.toIso8601String()}Z"),
        endTime: TemporalDateTime.fromString("${endTime.toIso8601String()}Z"));
    await Amplify.DataStore.save(activityDuration);
  }
}

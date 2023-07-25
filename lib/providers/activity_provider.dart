import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/models/ModelProvider.dart';
import 'package:tracker_app/utils/datetime_utils.dart';

extension ActivityExtension on Activity {
  List<ActivityDuration> historyWhere({required DateTimeRange range}) {
    final history = this.history;
    if (history != null) {
      return history
          .where((timePeriod) => timePeriod.startTime
              .getDateTimeInUtc()
              .isBetweenRange(range: range))
          .toList();
    }
    return [];
  }
}

extension ActivityDurationExtension on ActivityDuration {
  Duration duration() {
    return endTime.getDateTimeInUtc().difference(startTime.getDateTimeInUtc());
  }
}

class ActivityProvider extends ChangeNotifier {
  List<Activity> _activities = [];

  List<Activity> get activities {
    return [..._activities];
  }

  void listActivities() {}

  Future<Activity?> addNewActivity({required String name}) async {
    final activity = Activity(name: name);
    final activityToCreate = ModelMutations.create(activity);
    final response =
        await Amplify.API.mutate(request: activityToCreate).response;
    final createdActivity = response.data;
    final isCreated = createdActivity != null;
    if (isCreated) {
      _activities.add(createdActivity);
      notifyListeners();
    }
    return createdActivity;
  }

  Future<Activity?> editNewActivity(
      {required Activity oldActivity, required String newActivityName}) async {
    final activityToUpdate = oldActivity.copyWith(name: newActivityName);
    final request = ModelMutations.update(activityToUpdate);
    final response = await Amplify.API.mutate(request: request).response;
    var updatedActivity = response.data;
    final isUpdated = updatedActivity != null;
    if (isUpdated) {
      _activities = _activities
          .map((activity) =>
              activity.id == updatedActivity.id ? updatedActivity : activity)
          .toList();
      notifyListeners();
    }
    return updatedActivity;
  }

  Future<Activity?> removeActivity({required Activity activity}) async {
    final activityToRemove = ModelMutations.deleteById(
        Activity.classType, ActivityModelIdentifier(id: activity.id));
    final response =
        await Amplify.API.mutate(request: activityToRemove).response;
    final deletedActivity = response.data;
    final isDeleted = deletedActivity != null;
    if (isDeleted) {
      _activities.removeWhere((activity) => activity.id == activityToRemove.id);
      notifyListeners();
    }
    return deletedActivity;
  }
}

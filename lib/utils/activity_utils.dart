import 'package:flutter/material.dart';
import 'package:tracker_app/utils/datetime_utils.dart';

import '../models/ActivityDuration.dart';

List<ActivityDuration> activityDurationsWhere(
    {required List<ActivityDuration> activityDurations,
    required DateTimeRange range}) {
  return activityDurations
      .where((timePeriod) =>
          timePeriod.startTime.getDateTimeInUtc().isBetweenRange(range: range))
      .toList();
}

extension ActivityDurationExtension on ActivityDuration {
  Duration duration() {
    return endTime.getDateTimeInUtc().difference(startTime.getDateTimeInUtc());
  }
}

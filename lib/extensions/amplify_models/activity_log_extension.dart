import 'dart:convert';

import 'package:tracker_app/models/ModelProvider.dart';

import '../../dtos/appsync/activity_log_dto.dart';
import '../../shared_prefs.dart';

extension ActivityLogExtension on ActivityLog {

  ActivityLogDto dto() {
    final dataJson = jsonDecode(data);
    final name = dataJson["name"] ?? "";
    final notes = dataJson["notes"] ?? "";
    final startTime = DateTime.parse(dataJson["startTime"]);
    final endTime = DateTime.parse(dataJson["endTime"]);

    return ActivityLogDto(
      id: id,
      name: name,
      notes: notes,
      startTime: startTime,
      endTime: endTime,
      createdAt: createdAt.getDateTimeInUtc(),
      updatedAt: updatedAt.getDateTimeInUtc(), owner: SharedPrefs().userId,
    );
  }

}
import 'dart:async';
import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:tracker_app/dtos/appsync/activity_log_dto.dart';
import 'package:tracker_app/extensions/amplify_models/activity_log_extension.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';

import '../../models/ActivityLog.dart';
import '../../shared_prefs.dart';

class AmplifyActivityLogRepository {
  List<ActivityLogDto> _logs = [];

  UnmodifiableListView<ActivityLogDto> get logs => UnmodifiableListView(_logs);

  void loadLogsStream({required List<ActivityLog> logs}) {
    _mapLogs(logs: logs);
  }

  void _mapLogs({required List<ActivityLog> logs}) {
    _logs = logs.map((log) => log.dto()).sorted((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<ActivityLogDto> saveLog({required ActivityLogDto logDto}) async {
    final datetime = TemporalDateTime.withOffset(logDto.endTime, Duration.zero);

    final logToCreate = ActivityLog(data: jsonEncode(logDto), createdAt: datetime, updatedAt: datetime);
    await Amplify.DataStore.save<ActivityLog>(logToCreate);

    final updatedActivityWithId = logDto.copyWith(id: logToCreate.id, owner: SharedPrefs().userId);

    _logs.add(updatedActivityWithId);
    _logs.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return updatedActivityWithId;
  }

  Future<void> updateLog({required ActivityLogDto log}) async {
    final result = (await Amplify.DataStore.query(
      ActivityLog.classType,
      where: ActivityLog.ID.eq(log.id),
    ));

    if (result.isNotEmpty) {
      final oldLog = result.first;
      final newLog = oldLog.copyWith(data: jsonEncode(log));
      await Amplify.DataStore.save<ActivityLog>(newLog);
      final index = _indexWhereLog(id: log.id);
      if (index > -1) {
        _logs[index] = log;
      }
    }
  }

  Future<void> removeLog({required ActivityLogDto log}) async {
    final result = (await Amplify.DataStore.query(
      ActivityLog.classType,
      where: ActivityLog.ID.eq(log.id),
    ));

    if (result.isNotEmpty) {
      final oldTemplate = result.first;
      await Amplify.DataStore.delete<ActivityLog>(oldTemplate);
      final index = _indexWhereLog(id: log.id);
      if (index > -1) {
        _logs.removeAt(index);
      }
    }
  }

  /// Helper methods

  int _indexWhereLog({required String id}) {
    return _logs.indexWhere((log) => log.id == id);
  }

  ActivityLogDto? logWhereId({required String id}) {
    return _logs.firstWhereOrNull((log) => log.id == id);
  }

  /// RoutineLog for the following [DateTime]
  /// Day, Month and Year - Looking for a log in the same day, hence the need to match the day, month and year
  /// Month and Year - Looking for a log in the same month day, hence the need to match the month and year
  /// Year - Looking for a log in the same year, hence the need to match the year
  ActivityLogDto? whereLogIsSameDay({required DateTime dateTime}) {
    return _logs.firstWhereOrNull((log) => log.createdAt.isSameDayMonthYear(dateTime));
  }

  ActivityLogDto? whereLogIsSameMonth({required DateTime dateTime}) {
    return _logs.firstWhereOrNull((log) => log.createdAt.isSameMonthYear(dateTime));
  }

  ActivityLogDto? whereLogIsSameYear({required DateTime dateTime}) {
    return _logs.firstWhereOrNull((log) => log.createdAt.isSameYear(dateTime));
  }

  /// RoutineLogs for the following [DateTime]
  /// Day, Month and Year - Looking for logs in the same day, hence the need to match the day, month and year
  /// Month and Year - Looking for logs in the same month day, hence the need to match the month and year
  /// Year - Looking for logs in the same year, hence the need to match the year
  List<ActivityLogDto> whereLogsIsSameDay({required DateTime dateTime}) {
    return _logs.where((log) => log.createdAt.isSameDayMonthYear(dateTime)).toList();
  }

  List<ActivityLogDto> whereLogsIsSameMonth({required DateTime dateTime}) {
    return _logs.where((log) => log.createdAt.isSameMonthYear(dateTime)).toList();
  }

  List<ActivityLogDto> whereLogsIsSameYear({required DateTime dateTime}) {
    return _logs.where((log) => log.createdAt.isSameYear(dateTime)).toList();
  }

  void clear() {
    _logs.clear();
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/activity_log_dto.dart';
import 'package:tracker_app/extensions/activity_log_extension.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';

import '../models/ActivityLog.dart';
import '../models/RoutineLog.dart';
import '../utils/routine_utils.dart';

class AmplifyActivityLogRepository {
  List<ActivityLogDto> _activityLogs = [];

  Map<DateTimeRange, List<ActivityLogDto>> _weeklyLogs = {};

  Map<DateTimeRange, List<ActivityLogDto>> _monthlyLogs = {};

  UnmodifiableListView<ActivityLogDto> get activityLogs => UnmodifiableListView(_activityLogs);

  UnmodifiableMapView<DateTimeRange, List<ActivityLogDto>> get weeklyLogs => UnmodifiableMapView(_weeklyLogs);

  UnmodifiableMapView<DateTimeRange, List<ActivityLogDto>> get monthlyLogs => UnmodifiableMapView(_monthlyLogs);

  void _groupActivityLogs() {
    _weeklyLogs = groupActivityLogsByWeek(activityLogs: _activityLogs);
    _monthlyLogs = groupActivityLogsByMonth(activityLogs: _activityLogs);
  }

  Future<void> fetchLogs({required bool firstLaunch}) async {
    if (firstLaunch) {
      final now = DateTime.now().withoutTime();
      final then = DateTime(now.year - 1);
      final range = DateTimeRange(start: then, end: now);
      List<ActivityLog> logs = await queryLogsCloud(range: range);
      _mapLogs(logs: logs);
    } else {
      List<ActivityLog> logs = await Amplify.DataStore.query(ActivityLog.classType);
      _mapLogs(logs: logs);
    }
  }

  Future<List<ActivityLog>> queryLogsCloud({required DateTimeRange range}) async {
    final startOfCurrentYear = range.start.toIso8601String();
    final endOfCurrentYear = range.end.toIso8601String();
    final whereDate = ActivityLog.CREATEDAT.between(startOfCurrentYear, endOfCurrentYear);
    final request = ModelQueries.list(ActivityLog.classType, where: whereDate, limit: 999);
    final response = await Amplify.API.query(request: request).response;
    final routineLogs = response.data?.items.whereType<ActivityLog>().toList();
    return routineLogs ?? [];
  }

  void _mapLogs({required List<ActivityLog> logs}) {
    _activityLogs = logs.map((log) => log.dto()).sorted((a, b) => a.createdAt.compareTo(b.createdAt));
    _groupActivityLogs();
  }

  Future<ActivityLogDto> saveLog({required ActivityLogDto logDto}) async {
    final datetime = TemporalDateTime.withOffset(logDto.endTime, Duration.zero);

    final logToCreate = ActivityLog(data: jsonEncode(logDto), createdAt: datetime, updatedAt: datetime);
    await Amplify.DataStore.save(logToCreate);

    final updatedActivityWithId = logDto.copyWith(id: logToCreate.id);

    _activityLogs.add(updatedActivityWithId);
    _activityLogs.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    _groupActivityLogs();

    return updatedActivityWithId;
  }

  Future<void> updateLog({required ActivityLogDto log}) async {
    final result = (await Amplify.DataStore.query(
      RoutineLog.classType,
      where: RoutineLog.ID.eq(log.id),
    ));

    if (result.isNotEmpty) {
      final oldLog = result.first;
      final newLog = oldLog.copyWith(data: jsonEncode(log));
      await Amplify.DataStore.save(newLog);
      final index = _indexWhereRoutineLog(id: log.id);
      _activityLogs[index] = log;
      _groupActivityLogs();
    }
  }

  Future<void> removeLog({required ActivityLogDto log}) async {
    final result = (await Amplify.DataStore.query(
      RoutineLog.classType,
      where: ActivityLog.ID.eq(log.id),
    ));

    if (result.isNotEmpty) {
      final oldTemplate = result.first;
      await Amplify.DataStore.delete(oldTemplate);
      final index = _indexWhereRoutineLog(id: log.id);
      _activityLogs.removeAt(index);
      _groupActivityLogs();
    }
  }

  /// Helper methods

  int _indexWhereRoutineLog({required String id}) {
    return _activityLogs.indexWhere((log) => log.id == id);
  }

  ActivityLogDto? logWhereId({required String id}) {
    return _activityLogs.firstWhereOrNull((log) => log.id == id);
  }

  List<ActivityLogDto> logsWhereDate({required DateTime dateTime}) {
    return _activityLogs.where((log) => log.createdAt.isSameDayMonthYear(dateTime)).toList();
  }

  ActivityLogDto? logWhereDate({required DateTime dateTime}) {
    return _activityLogs.firstWhereOrNull((log) => log.createdAt.isSameDayMonthYear(dateTime));
  }

  void clear() {
    _activityLogs.clear();
    _weeklyLogs.clear();
    _monthlyLogs.clear();
  }
}

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:tracker_app/models/ActivityLog.dart';

import '../dtos/activity_log_dto.dart';
import '../repositories/amplify_activity_log_repository.dart';

class ActivityLogController extends ChangeNotifier {
  String errorMessage = '';

  late AmplifyActivityLogRepository _amplifyActivityLogRepository;

  ActivityLogController(AmplifyActivityLogRepository amplifyLogRepository) {
    _amplifyActivityLogRepository = amplifyLogRepository;
  }

  UnmodifiableListView<ActivityLogDto> get activityLogs => _amplifyActivityLogRepository.activityLogs;

  UnmodifiableMapView<DateTimeRange, List<ActivityLogDto>> get weeklyLogs => _amplifyActivityLogRepository.weeklyLogs;

  UnmodifiableMapView<DateTimeRange, List<ActivityLogDto>> get monthlyLogs => _amplifyActivityLogRepository.monthlyLogs;

  void streamLogs({required List<ActivityLog> logs}) async {
    _amplifyActivityLogRepository.loadLogsStream(logs: logs);
    notifyListeners();
  }

  Future<List<ActivityLog>> fetchLogsCloud({required DateTimeRange range}) async {
    return _amplifyActivityLogRepository.queryLogsCloud(range: range);
  }

  Future<ActivityLogDto?> saveLog({required ActivityLogDto logDto}) async {
    ActivityLogDto? savedLog;
    try {
      savedLog = await _amplifyActivityLogRepository.saveLog(logDto: logDto);
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
    } finally {
      notifyListeners();
    }
    return savedLog;
  }

  Future<void> updateLog({required ActivityLogDto log}) async {
    try {
      await _amplifyActivityLogRepository.updateLog(log: log);
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
    } finally {
      notifyListeners();
    }
  }

  Future<void> removeLog({required ActivityLogDto log}) async {
    try {
      await _amplifyActivityLogRepository.removeLog(log: log);
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
    } finally {
      notifyListeners();
    }
  }

  /// Helper methods

  ActivityLogDto? logWhereId({required String id}) {
    return _amplifyActivityLogRepository.logWhereId(id: id);
  }

  ActivityLogDto? whereLogIsSameDay({required DateTime dateTime}) {
    return _amplifyActivityLogRepository.whereLogIsSameDay(dateTime: dateTime);
  }

  ActivityLogDto? whereLogIsSameMonth({required DateTime dateTime}) {
    return _amplifyActivityLogRepository.whereLogIsSameMonth(dateTime: dateTime);
  }

  ActivityLogDto? whereLogIsSameYear({required DateTime dateTime}) {
    return _amplifyActivityLogRepository.whereLogIsSameYear(dateTime: dateTime);
  }

  List<ActivityLogDto> whereLogsIsSameDay({required DateTime dateTime}) {
    return _amplifyActivityLogRepository.whereLogsIsSameDay(dateTime: dateTime);
  }

  List<ActivityLogDto> whereLogsIsSameMonth({required DateTime dateTime}) {
    return _amplifyActivityLogRepository.whereLogsIsSameMonth(dateTime: dateTime);
  }

  List<ActivityLogDto> whereLogsIsSameYear({required DateTime dateTime}) {
    return _amplifyActivityLogRepository.whereLogsIsSameYear(dateTime: dateTime);
  }

  void clear() {
    _amplifyActivityLogRepository.clear();
    notifyListeners();
  }
}

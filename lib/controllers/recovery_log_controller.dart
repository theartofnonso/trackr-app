import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:tracker_app/models/RecoveryLog.dart';

import '../dtos/appsync/recovery_log_dto.dart';
import '../logger.dart';
import '../repositories/amplify/amplify_recovery_log_repository.dart';

class RecoveryLogController extends ChangeNotifier {
  String errorMessage = '';

  late AmplifyRecoveryLogRepository _amplifyRecoveryLogRepository;

  final logger = getLogger(className: "RecoveryLogController");

  RecoveryLogController(AmplifyRecoveryLogRepository amplifyLogRepository) {
    _amplifyRecoveryLogRepository = amplifyLogRepository;
  }

  UnmodifiableListView<RecoveryLogDto> get logs => _amplifyRecoveryLogRepository.logs;

  void streamLogs({required List<RecoveryLog> logs}) async {
    _amplifyRecoveryLogRepository.loadLogsStream(logs: logs);
    notifyListeners();
  }

  void saveLog({required RecoveryLogDto logDto}) {
    try {
      _amplifyRecoveryLogRepository.saveLog(logDto: logDto);
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
      logger.e("Error saving log", error: e);
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateLog({required RecoveryLogDto log}) async {
    try {
      await _amplifyRecoveryLogRepository.updateLog(log: log);
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
      logger.e("Error updating log", error: e);
    } finally {
      notifyListeners();
    }
  }

  Future<void> removeLog({required RecoveryLogDto log}) async {
    try {
      await _amplifyRecoveryLogRepository.removeLog(log: log);
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
      logger.e("Error removing log", error: e);
    } finally {
      notifyListeners();
    }
  }

  /// Helper methods

  RecoveryLogDto? logWhereId({required String id}) {
    return _amplifyRecoveryLogRepository.logWhereId(id: id);
  }

  RecoveryLogDto? whereLogIsSameDay({required DateTime dateTime}) {
    return _amplifyRecoveryLogRepository.whereLogIsSameDay(dateTime: dateTime);
  }

  RecoveryLogDto? whereLogIsSameMonth({required DateTime dateTime}) {
    return _amplifyRecoveryLogRepository.whereLogIsSameMonth(dateTime: dateTime);
  }

  RecoveryLogDto? whereLogIsSameYear({required DateTime dateTime}) {
    return _amplifyRecoveryLogRepository.whereLogIsSameYear(dateTime: dateTime);
  }

  List<RecoveryLogDto> whereLogsIsSameDay({required DateTime dateTime}) {
    return _amplifyRecoveryLogRepository.whereLogsIsSameDay(dateTime: dateTime);
  }

  List<RecoveryLogDto> whereLogsIsSameMonth({required DateTime dateTime}) {
    return _amplifyRecoveryLogRepository.whereLogsIsSameMonth(dateTime: dateTime);
  }

  List<RecoveryLogDto> whereLogsIsSameYear({required DateTime dateTime}) {
    return _amplifyRecoveryLogRepository.whereLogsIsSameYear(dateTime: dateTime);
  }

  List<RecoveryLogDto> whereLogsIsWithinRange({required DateTimeRange range}) {
    return _amplifyRecoveryLogRepository.whereLogsIsWithinRange(range: range);
  }

  void clear() {
    _amplifyRecoveryLogRepository.clear();
    notifyListeners();
  }
}

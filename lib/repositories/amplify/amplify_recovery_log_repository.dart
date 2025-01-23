import 'dart:async';
import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';

import '../../dtos/appsync/recovery_log_dto.dart';
import '../../enums/posthog_analytics_event.dart';
import '../../logger.dart';
import '../../models/RecoveryLog.dart';
import '../../shared_prefs.dart';

class AmplifyRecoveryLogRepository {
  final logger = getLogger(className: "AmplifyRecoveryLogRepository");

  List<RecoveryLogDto> _logs = [];

  UnmodifiableListView<RecoveryLogDto> get logs => UnmodifiableListView(_logs);

  void loadLogsStream({required List<RecoveryLog> logs}) {
    _logs = logs.map((log) => RecoveryLogDto.toDto(log)).toList();
  }

  Future<void> saveLog({required RecoveryLogDto logDto}) async {
    final datetime = TemporalDateTime.now();

    final logToCreate =
        RecoveryLog(data: jsonEncode(logDto), createdAt: datetime, updatedAt: datetime, owner: SharedPrefs().userId);

    await Amplify.DataStore.save<RecoveryLog>(logToCreate);

    Posthog().capture(eventName: PostHogAnalyticsEvent.logActivity.displayName, properties: logDto.toJson());

    logger.i("Created recovery log: $logDto");
  }

  Future<void> updateLog({required RecoveryLogDto log}) async {
    final result = (await Amplify.DataStore.query(
      RecoveryLog.classType,
      where: RecoveryLog.ID.eq(log.id),
    ));

    if (result.isNotEmpty) {
      final oldLog = result.first;
      final createdAt = TemporalDateTime.withOffset(log.createdAt, Duration.zero);
      final updatedAt = TemporalDateTime.withOffset(log.updatedAt, Duration.zero);
      final newLog = oldLog.copyWith(data: jsonEncode(log), createdAt: createdAt, updatedAt: updatedAt);
      await Amplify.DataStore.save<RecoveryLog>(newLog);
      logger.i("Updated recovery log: $log");
    }
  }

  Future<void> removeLog({required RecoveryLogDto log}) async {
    final result = (await Amplify.DataStore.query(
      RecoveryLog.classType,
      where: RecoveryLog.ID.eq(log.id),
    ));

    if (result.isNotEmpty) {
      final oldTemplate = result.first;
      await Amplify.DataStore.delete<RecoveryLog>(oldTemplate);
      logger.i("Removed recovery log: $log");
    }
  }

  /// Helper methods

  RecoveryLogDto? logWhereId({required String id}) {
    return _logs.firstWhereOrNull((log) => log.id == id);
  }

  /// RoutineLog for the following [DateTime]
  /// Day, Month and Year - Looking for a log in the same day, hence the need to match the day, month and year
  /// Month and Year - Looking for a log in the same month day, hence the need to match the month and year
  /// Year - Looking for a log in the same year, hence the need to match the year
  RecoveryLogDto? whereLogIsSameDay({required DateTime dateTime}) {
    return _logs.firstWhereOrNull((log) => log.createdAt.isSameDayMonthYear(dateTime));
  }

  RecoveryLogDto? whereLogIsSameMonth({required DateTime dateTime}) {
    return _logs.firstWhereOrNull((log) => log.createdAt.isSameMonthYear(dateTime));
  }

  RecoveryLogDto? whereLogIsSameYear({required DateTime dateTime}) {
    return _logs.firstWhereOrNull((log) => log.createdAt.isSameYear(dateTime));
  }

  /// RoutineLogs for the following [DateTime]
  /// Day, Month and Year - Looking for logs in the same day, hence the need to match the day, month and year
  /// Month and Year - Looking for logs in the same month day, hence the need to match the month and year
  /// Year - Looking for logs in the same year, hence the need to match the year
  List<RecoveryLogDto> whereLogsIsSameDay({required DateTime dateTime}) {
    return _logs.where((log) => log.createdAt.isSameDayMonthYear(dateTime)).toList();
  }

  List<RecoveryLogDto> whereLogsIsSameMonth({required DateTime dateTime}) {
    return _logs.where((log) => log.createdAt.isSameMonthYear(dateTime)).toList();
  }

  List<RecoveryLogDto> whereLogsIsSameYear({required DateTime dateTime}) {
    return _logs.where((log) => log.createdAt.isSameYear(dateTime)).toList();
  }

  List<RecoveryLogDto> whereLogsIsWithinRange({required DateTimeRange range}) {
    return _logs.where((log) => log.createdAt.isBetweenInclusive(from: range.start, to: range.end)).toList();
  }

  void clear() {
    _logs.clear();
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:tracker_app/extensions/amplify_models/challenge_log_extension.dart';

import '../../dtos/appsync/challenge_log_dto.dart';
import '../../models/ChallengeLog.dart';

class AmplifyChallengeLogRepository {
  List<ChallengeLogDto> _logs = [];

  UnmodifiableListView<ChallengeLogDto> get logs => UnmodifiableListView(_logs);

  void loadLogsStream({required List<ChallengeLog> logs}) {
    _mapLogs(logs: logs);
  }

  void _mapLogs({required List<ChallengeLog> logs}) {
      _logs = logs.map((log) => log.dto()).toList();
  }

  Future<void> saveLog({required ChallengeLogDto logDto}) async {
    final datetime = TemporalDateTime.withOffset(logDto.startDate, Duration.zero);

    final logToCreate = ChallengeLog(data: jsonEncode(logDto), createdAt: datetime, updatedAt: datetime);
    await Amplify.DataStore.save<ChallengeLog>(logToCreate);

    final updatedChallengeWithId = logDto.copyWith(id: logToCreate.id);

    _logs.add(updatedChallengeWithId);

  }

  Future<void> removeLog({required ChallengeLogDto log}) async {
    final result = (await Amplify.DataStore.query(
      ChallengeLog.classType,
      where: ChallengeLog.ID.eq(log.id),
    ));

    if (result.isNotEmpty) {
      final oldChallenge = result.first;
      await Amplify.DataStore.delete<ChallengeLog>(oldChallenge);
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

  ChallengeLogDto? logWhereId({required String id}) {
    return _logs.firstWhereOrNull((log) => log.id == id);
  }

  ChallengeLogDto? logWhereChallengeTemplateId({required String id}) {
    return _logs.firstWhereOrNull((log) => log.templateId == id);
  }

  void clear() {
    _logs.clear();
  }
}

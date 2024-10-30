import 'dart:collection';

import 'package:flutter/material.dart';

import '../dtos/appsync/challenge_log_dto.dart';
import '../models/ChallengeLog.dart';
import '../repositories/amplify/amplify_challenge_log_repository.dart';

class ChallengeLogController extends ChangeNotifier {
  String errorMessage = '';

  late AmplifyChallengeLogRepository _amplifyChallengeLogRepository;

  ChallengeLogController(AmplifyChallengeLogRepository amplifyLogRepository) {
    _amplifyChallengeLogRepository = amplifyLogRepository;
  }

  UnmodifiableListView<ChallengeLogDto> get logs => _amplifyChallengeLogRepository.logs;

  void streamLogs({required List<ChallengeLog> logs}) async {
    _amplifyChallengeLogRepository.loadLogsStream(logs: logs);
    notifyListeners();
  }

  Future<void> saveLog({required ChallengeLogDto logDto}) async {
    try {
      await _amplifyChallengeLogRepository.saveLog(logDto: logDto);
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
    } finally {
      notifyListeners();
    }
  }

  Future<void> removeLog({required ChallengeLogDto log}) async {
    try {
      await _amplifyChallengeLogRepository.removeLog(log: log);
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
    } finally {
      notifyListeners();
    }
  }

  ChallengeLogDto? logWhereChallengeTemplateId({required String id}) {
    return _amplifyChallengeLogRepository.logWhereChallengeTemplateId(id: id);
  }


  void clear() {
    _amplifyChallengeLogRepository.clear();
    notifyListeners();
  }
}

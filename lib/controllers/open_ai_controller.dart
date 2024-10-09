import 'package:flutter/material.dart';

import '../enums/open_ai_enums.dart';
import '../repositories/open_ai_repository.dart';

class OpenAIController extends ChangeNotifier {
  late OpenAIRepository _openAIRepository;

  String? _threadId;

  String? _runId;

  bool _isRunComplete = false;

  String _message = "";

  bool get isRunComplete => _isRunComplete;

  String get message => _message;

  OpenAIController(OpenAIRepository amplifyLogRepository) {
    _openAIRepository = amplifyLogRepository;
  }

  void createThread() async {
    final threadId = await _openAIRepository.createThread();
    _threadId = threadId;
  }

  Future<void> addMessage({required String prompt, required OpenAiEnums mode}) async {
    final threadId = _threadId;
    if (threadId != null) {
      final runId = await _openAIRepository.addMessage(threadId: threadId, prompt: prompt, mode: mode);
      print("New message added");
      _runId = runId;
      print("New Run id: $_runId");
    }
  }

  void checkRunStatus() async {
    final threadId = _threadId;
    if (threadId != null) {
      final runId = _runId;
      if (runId != null) {
        final status = await _openAIRepository.checkRunStatus(threadId: threadId, runId: runId);
        _isRunComplete = status;
        print("Checking Run status: $_isRunComplete");
        notifyListeners();
      }
    }
  }

  void processMessages() async {
    if (_isRunComplete) {
      final threadId = _threadId;
      if (threadId != null) {
        final runId = _runId;
        if (runId != null) {
          final messages = await _openAIRepository.listMessages(threadId: threadId, runId: runId);
          final mostRecentMessage = messages.first as dynamic;
          final contents = mostRecentMessage["content"] as List<dynamic>;
          final firstContent = contents.first as dynamic;
          final text = firstContent["text"] as dynamic;
          final value = text["value"] as dynamic;
          _message = value;
          print(_message);
          notifyListeners();
        }
      }
    }
  }

  void onClear() {
    _threadId = "";
    _runId = "";
    _isRunComplete = false;
    _message = "";
  }
}

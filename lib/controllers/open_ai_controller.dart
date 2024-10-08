import 'package:flutter/material.dart';

import '../repositories/open_ai_repository.dart';

class OpenAIController extends ChangeNotifier {
  String errorMessage = '';

  late OpenAIRepository _openAIRepository;

  String? _threadId;

  String? _runId;

  OpenAIController(OpenAIRepository amplifyLogRepository) {
    _openAIRepository = amplifyLogRepository;
  }

  void createThread() async {
    final threadId = await _openAIRepository.createThread();
    _threadId = threadId;
    notifyListeners();
  }

  void addMessage({required String messagePrompt}) async {
    final threadId = _threadId;
    if (threadId != null) {
      await _openAIRepository.addMessage(threadId: threadId, messagePrompt: messagePrompt);
    }
  }

  void run({required Map<String, String> json}) async {
    final threadId = _threadId;
    if (threadId != null) {
      final runId = await _openAIRepository.run(threadId: threadId, json: json);
      _runId = runId;
    }
  }
}

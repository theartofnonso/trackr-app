import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';

import '../repositories/open_ai_repository.dart';

class OpenAIController extends ChangeNotifier {
  late OpenAIRepository _openAIRepository;

  String? _threadId;

  String? _runId;

  bool _isRunComplete = false;

  List<ExerciseLogDto> _exerciseTemplates = [];

  bool get isRunComplete => _isRunComplete;

  List<ExerciseLogDto> get _exerciseLogs => _exerciseTemplates;

  OpenAIController(OpenAIRepository amplifyLogRepository) {
    _openAIRepository = amplifyLogRepository;
  }

  void createThread() async {
    final threadId = await _openAIRepository.createThread();
    _threadId = threadId;
  }

  Future<void> addMessage({required String prompt}) async {
    final threadId = _threadId;
    if (threadId != null) {
      await _openAIRepository.addMessage(threadId: threadId, prompt: prompt);
      final runId = await _openAIRepository.runThread(threadId: threadId);
      _runId = runId;
    }
  }

  void checkRunStatus() async {
    final threadId = _threadId;
    final runId = _runId;
    if (threadId != null) {
      if (runId != null) {
        final status = await _openAIRepository.checkRunStatus(threadId: threadId, runId: runId);
        _isRunComplete = status;
        notifyListeners();
      }
    }
  }

  void processMessages() async {
    if (_isRunComplete) {
      final threadId = _threadId;
      if (threadId != null) {
        final messages = await _openAIRepository.listMessages(threadId: threadId);
        final firstMessage = messages.first as dynamic;
        if (firstMessage != null) {
          final contents = firstMessage["content"] as List<dynamic>;
          final firstContent = contents.first as dynamic;
          if (firstContent != null) {
            final text = firstContent["text"] as dynamic;
            final jsonString = text["value"] as String;

            // Decode the JSON string
            Map<String, dynamic> jsonData = jsonDecode(jsonString);
            print(jsonData);

            // Extract the exercises list
            List<String> exercises = List<String>.from(jsonData['exercises']);

            // Print the exercises
            print('Exercises: $exercises');
          }
        }
      }
    }
  }
}

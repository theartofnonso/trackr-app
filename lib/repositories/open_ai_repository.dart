import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:http/http.dart' as http;

import '../enums/open_ai_enums.dart';
import '../strings.dart';

class OpenAIRepository {
  static const String _apiKey =
      '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';

  final headers = {
    'Authorization': 'Bearer $_apiKey',
    'Content-Type': 'application/json',
    'OpenAI-Beta': 'assistants=v2',
  };

  Future<String?> createThread() async {
    const threadsEndpoint = 'https://api.openai.com/v1/threads';

    String? threadId;

    final body = jsonEncode({
      'tool_resources': {
        'file_search': {
          'vector_store_ids': ['vs_HySuyyIKYlokbO3g7abXwdg3']
        },
      }
    });

    try {
      // Send POST request
      final response = await http.post(
        Uri.parse(threadsEndpoint),
        headers: headers,
        body: body,
      );

      // Check for successful response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        threadId = data["id"];
      }
    } catch (e) {
      safePrint('Request failed: $e');
    }

    return threadId;
  }

  Future<String?> addMessage({required String threadId, required String prompt, required OpenAiEnums mode}) async {

    String? runId;

    final messagesEndpoint = "https://api.openai.com/v1/threads/$threadId/messages";

    final body = jsonEncode({'role': 'user', 'content': prompt});

    try {
      // Send POST request
      final response = await http.post(
        Uri.parse(messagesEndpoint),
        headers: headers,
        body: body,
      );
      if (response.statusCode == 200) {
        final instructions = mode == OpenAiEnums.template
            ? openAITemplateAssistantInstructions
            : openAIGenericAssistantInstructions;

        runId =  await _runThread(threadId: threadId, instructions: instructions);
      }
    } catch (e) {
      print('Request failed: $e');
    }

    return runId;
  }

  Future<String?> _runThread({required String threadId, required String instructions}) async {
    String? runId;

    final runsEndpoint = "https://api.openai.com/v1/threads/$threadId/runs";

    final body = jsonEncode({
      'assistant_id': 'asst_dye87dwWWqq5tU7VHOkPi3hb',
      'tool_choice': {"type": "file_search"},
      'instructions': instructions
    });

    try {
      // Send POST request
      final response = await http.post(
        Uri.parse(runsEndpoint),
        headers: headers,
        body: body,
      );

      // Check for successful response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        runId = data["id"];
      }
    } catch (e) {
      print('Request failed: $e');
    }

    return runId;
  }

  Future<bool> checkRunStatus({required String threadId, required String runId}) async {
    bool isComplete = false;

    final runEndpoint = "https://api.openai.com/v1/threads/$threadId/runs/$runId";

    try {
      // Send POST request
      final response = await http.get(
        Uri.parse(runEndpoint),
        headers: headers,
      );

      // Check for successful response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data["status"] as String;
        isComplete = status == "completed";
      }
    } catch (e) {
      print('Request failed: $e');
    }

    return isComplete;
  }

  Future<List<dynamic>> listMessages({required String threadId, required String runId}) async {
    List<dynamic> messages = [];

    final messagesEndpoint = "https://api.openai.com/v1/threads/$threadId/messages";

    try {
      final Map<String, String> queryParameters = {
        'order': 'desc',
        'run_id': runId
      };

      // Send GET request
      final response = await http.get(
        Uri.parse(messagesEndpoint).replace(queryParameters: queryParameters),
        headers: headers,
      );

      // Check for successful response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        messages = data["data"] as List<dynamic>;
      } else {

      }
    } catch (e) {
      print('Request failed: $e');
    }

    return messages;
  }
}

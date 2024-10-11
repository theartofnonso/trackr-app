import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:http/http.dart' as http;

import '../strings/ai_prompts.dart';

class OpenAIRepository {
  static const String _apiKey =
      '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';

  static const String _completionsAPIEndpoint = "https://api.openai.com/v1/chat/completions";

  final headers = {
    'Authorization': 'Bearer $_apiKey',
    'Content-Type': 'application/json',
    'OpenAI-Beta': 'assistants=v2',
  };

  Future<String?> runMessage({required String system, required String user}) async {
    String? message;

    final body = jsonEncode({
      "model": "gpt-4o-mini",
      "messages": [
        {"role": "system", "content": system},
        {"role": "user", "content": user}
      ]
    });

    try {
      // Send POST request
      final response = await http.post(
        Uri.parse(_completionsAPIEndpoint),
        headers: headers,
        body: body,
      );

      // Check for successful response
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        // Extract the most recent message
        final choices = body['choices'];

        if (choices.isNotEmpty) {
          message = choices[0]['message']['content'];
        }
      }
    } catch (e) {
      safePrint('Request failed: $e');
    }

    return message;
  }

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

  Future<String?> addMessage({required String threadId, required String prompt}) async {
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
        runId = await _runThread(threadId: threadId);
      }
    } catch (e) {
      print('Request failed: $e');
    }

    return runId;
  }

  Future<String?> _runThread({required String threadId}) async {
    String? runId;

    final runsEndpoint = "https://api.openai.com/v1/threads/$threadId/runs";

    final body = jsonEncode({
      'assistant_id': 'asst_dye87dwWWqq5tU7VHOkPi3hb',
      'tool_choice': {"type": "file_search"},
      'instructions': openAITemplateAssistantInstructions
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
      final Map<String, String> queryParameters = {'order': 'desc', 'run_id': runId};

      // Send GET request
      final response = await http.get(
        Uri.parse(messagesEndpoint).replace(queryParameters: queryParameters),
        headers: headers,
      );

      // Check for successful response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        messages = data["data"] as List<dynamic>;
      } else {}
    } catch (e) {
      print('Request failed: $e');
    }

    return messages;
  }
}

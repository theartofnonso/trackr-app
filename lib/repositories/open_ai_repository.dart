import 'dart:convert';

import 'package:http/http.dart' as http;

class OpenAIRepository {

  static const String _threadsEndpoint = 'https://api.openai.com/v1/threads';
  static const String _apiKey = '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';

  final headers = {
    'Authorization': 'Bearer $_apiKey',
    'Content-Type': 'application/json',
    'OpenAI-Beta': 'assistants=v2',
  };

  Future<String?> createThread() async {
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
        Uri.parse(_threadsEndpoint),
        headers: headers,
        body: body,
      );

      // Check for successful response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Success: $data');
      } else {
        print(response);
        print('Error: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Request failed: $e');
    }

    return threadId;
  }

  Future<void> addMessage({required String threadId, required String messagePrompt}) async {

    final threadsEndpoint = "https://api.openai.com/v1/threads/$threadId/messages";

    final body = jsonEncode({
      'role': 'user',
      'content': messagePrompt
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
        print('Success: $data');
      }
    } catch (e) {
      print('Request failed: $e');
    }

  }

  Future<String?> run({required String threadId, required Map<String, String> json}) async {
    String? runId;

    final threadsEndpoint = "https://api.openai.com/v1/threads/$threadId/messages";

    final body = jsonEncode({
      'assistant_id': 'asst_dye87dwWWqq5tU7VHOkPi3hb',
      'tool_choice': {"type": "file_search"},
      'response_format': { "type": "json_schema", "json_schema": json},
      'instructions': ''
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
        print('Success: $data');
      }
    } catch (e) {
      print('Request failed: $e');
    }

    return runId;
  }

}

import 'dart:convert';

import 'package:http/http.dart' as http;

class OpenAIRepository {

  static const String _threadsEndpoint = 'https://api.openai.com/v1/threads/';
  static const String _apiKey = 'sk-svcacct-pnzvz5NSbY4mLDkP1muT-a4_8v0UfD95czIgX6vHU5gpaiavzEtp12GMImS-BQUNFylur-UXsT3BlbkFJvSMVC_-hclGK-kDxTYVVGo9BKmJj967g2098Q_bYEh_pXlDIjzqN5270PWSRRqqq_5kWusFAA';

  final headers = {
    'Authorization': 'Bearer $_apiKey',
    'Content-Type': 'application/json',
    'OpenAI-Beta': 'assistants=v2',
  };

  Future<String?> createThread() async {
    String? threadId;

    final body = jsonEncode({
      'tool_resources': {
        'file_search': ['asst_abc123'],
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

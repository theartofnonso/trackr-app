import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:http/http.dart' as http;

import '../openAI/open_ai_functions.dart';

const String _apiKey =
    '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';

const String _completionsAPIEndpoint = "https://api.openai.com/v1/chat/completions";

final headers = {
  'Authorization': 'Bearer $_apiKey',
  'Content-Type': 'application/json',
};

Future<String?> runMessage({required String system, required String user}) async {
  String? message;

  final body = jsonEncode({
    "model": "gpt-4o-mini",
    "messages": [
      {"role": "system", "content": system},
      {"role": "user", "content": user}
    ],
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

Future<List<dynamic>?> runMessageWithFunctionCall({required String system, required String user}) async {
  List<dynamic>? message;

  final body = jsonEncode({
    "model": "gpt-4o-mini",
    "messages": [
      {"role": "system", "content": system},
      {"role": "user", "content": user}
    ],
    "tools": openAIFunctionTools,
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
      message = body['choices'] as List<dynamic>;
    }
  } catch (e) {
    safePrint('Request failed: $e');
  }

  return message;
}

Future<String?> runMessageWithFunctionCallResult({required String payload}) async {
  String? message;

  try {
    // Send POST request
    final response = await http.post(
      Uri.parse(_completionsAPIEndpoint),
      headers: headers,
      body: payload,
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

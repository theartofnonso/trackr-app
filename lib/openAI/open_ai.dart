import 'dart:convert';

import 'package:http/http.dart' as http;

import '../enums/open_ai_models.dart';

const String apiKey =
    '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';

const String completionsAPIEndpoint =
    "https://api.openai.com/v1/chat/completions";

final headers = {
  'Authorization': 'Bearer $apiKey',
  'Content-Type': 'application/json',
};

Future<dynamic> runMessageWithAudio(
    {required String system,
    required String user,
    required responseFormat,
    OpenAIModel model = OpenAIModel.fourOne}) async {
  dynamic message;

  final body = jsonEncode({
    "model": model.name,
    "messages": [
      {"role": "system", "content": system},
      {"role": "user", "content": user},
    ],
    "response_format": responseFormat
  });

  final response = await http.post(
    Uri.parse(completionsAPIEndpoint),
    headers: headers,
    body: body,
  );

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);

    final choices = body['choices'];
    if (choices.isNotEmpty) {
      message = choices[0]['message']['content'];
    }
  }

  return message;
}

Future<dynamic> runMessage(
    {required String system,
    required String user,
    required responseFormat,
    OpenAIModel model = OpenAIModel.fourOne}) async {
  dynamic message;

  final body = jsonEncode({
    "model": model.name,
    "messages": [
      {"role": "system", "content": system},
      {"role": "user", "content": user},
    ],
    "response_format": responseFormat
  });

  final response = await http.post(
    Uri.parse(completionsAPIEndpoint),
    headers: headers,
    body: body,
  );

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);

    final choices = body['choices'];
    if (choices.isNotEmpty) {
      message = choices[0]['message']['content'];
    }
  }

  return message;
}

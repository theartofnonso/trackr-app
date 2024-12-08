import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tracker_app/dtos/open_ai_response_schema_dtos/tool_dto.dart';

import '../enums/open_ai_models.dart';
import 'open_ai_functions.dart';

const String _apiKey =
    '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';

const String _completionsAPIEndpoint = "https://api.openai.com/v1/chat/completions";

final headers = {
  'Authorization': 'Bearer $_apiKey',
  'Content-Type': 'application/json',
};

Future<dynamic> runMessage(
    {required String system,
    required String user,
    required responseFormat,
    OpenAIModel model = OpenAIModel.fourOMini}) async {
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
    Uri.parse(_completionsAPIEndpoint),
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

Future<Map<String, dynamic>?> runMessageWithTools(
    {required String systemInstruction,
    required String userInstruction,
    OpenAIModel model = OpenAIModel.fourOMini}) async {
  Map<String, dynamic>? tools;

  final body = jsonEncode({
    "model": model.name,
    "messages": [
      {"role": "system", "content": systemInstruction},
      {"role": "user", "content": userInstruction}
    ],
    "tools": openAIFunctionTools,
  });

  final response = await http.post(
    Uri.parse(_completionsAPIEndpoint),
    headers: headers,
    body: body,
  );

  print(response.body);
  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);
    final choices = body['choices'] as List<dynamic>;
    if (choices.isNotEmpty) {
      final choice = choices[0];
      final message = choice['message'];
      final toolCalls = message['tool_calls'] as List<dynamic>?;
      if (toolCalls != null) {
        final toolId = toolCalls[0]['id'];
        final toolName = toolCalls[0]['function']['name'];
        tools = {"id": toolId, "name": toolName};
      }
    }
  }

  return tools;
}

Map<String, dynamic> createFunctionCallPayload(
    {required ToolDto tool,
    required String systemInstruction,
    required String user,
    required Map<String, Object> responseFormat,
    required String functionName,
    required String extra,
    OpenAIModel model = OpenAIModel.fourOMini}) {
  final functionCallMessage = {
    "role": "assistant",
    "tool_calls": [
      {
        "id": tool.id,
        "type": "function",
        "function": {"arguments": "{}", "name": functionName}
      }
    ]
  };

  final functionCallResultMessage = {"role": "tool", "content": extra, "tool_call_id": tool.id};

  final payload = {
    "model": model.name,
    "messages": [
      {"role": "system", "content": systemInstruction},
      {"role": "user", "content": user},
      functionCallMessage,
      functionCallResultMessage
    ],
    "response_format": responseFormat
  };

  return payload;
}

Future<dynamic> runMessageWithFunctionCallPayload({required Map<String, dynamic> payload}) async {
  dynamic message;

  // Send POST request
  final response = await http.post(
    Uri.parse(_completionsAPIEndpoint),
    headers: headers,
    body: jsonEncode(payload),
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

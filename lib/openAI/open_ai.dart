import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:http/http.dart' as http;

import '../dtos/appsync/exercise_dto.dart';
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

Future<dynamic> runMessageWithTools({required String systemInstruction, required String userInstruction, Function(String message)? callback}) async {
  dynamic tool;

  final body = jsonEncode({
    "model": "gpt-4o-mini",
    "messages": [
      {"role": "system", "content": systemInstruction},
      {"role": "user", "content": userInstruction}
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
      final choices = body['choices'] as List<dynamic>;
      if (choices.isNotEmpty) {
        final choice = choices[0];
        final message = choice['message'];
        final toolCalls = message['tool_calls'] as List<dynamic>?;
        if (toolCalls != null) {
          final toolId = toolCalls[0]['id'];
          final toolName = toolCalls[0]['function']['name'];
          tool = {
            "id": toolId,
            "name": toolName
          };
        } else {
          final content = message['content'];
          if(content != null) {
            final callbackFunction = callback;
            if(callbackFunction != null) {
              callbackFunction(content);
            }
          }
        }
      }
    }
  } catch (e) {
    safePrint('Request failed: $e');
  }

  return tool;
}

Future<String> createFunctionCallPayload(
    {required dynamic toolId,
    required String systemInstruction,
    required String user,
    required Map<String, Object> responseFormat,
    required List<ExerciseDto> exercises}) async {
  final functionCallMessage = {
    "role": "assistant",
    "tool_calls": [
      {
        "id": toolId,
        "type": "function",
        "function": {"arguments": "{}", "name": "list_exercises"}
      }
    ]
  };

  final listOfExerciseJsons = exercises
      .map((exercise) => jsonEncode({
            "id": exercise.id,
            "name": exercise.name,
            "primary_muscle_group": exercise.primaryMuscleGroup.name,
            "secondary_muscle_groups": exercise.secondaryMuscleGroups.map((muscleGroup) => muscleGroup.name).toList()
          }))
      .toList();

  final functionCallResultMessage = {
    "role": "tool",
    "content": jsonEncode({
      "exercises": listOfExerciseJsons,
    }),
    "tool_call_id": toolId
  };

  final payload = jsonEncode({
    "model": "gpt-4o-mini",
    "messages": [
      {"role": "system", "content": systemInstruction},
      {"role": "user", "content": user},
      functionCallMessage,
      functionCallResultMessage
    ],
    "response_format": responseFormat
  });
  return payload;
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

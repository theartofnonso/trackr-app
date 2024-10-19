import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/routine_template_dto.dart';

import '../controllers/exercise_controller.dart';
import '../dtos/exercise_log_dto.dart';
import '../dtos/set_dto.dart';
import '../openAI/open_ai_functions.dart';
import '../shared_prefs.dart';
import '../strings/ai_prompts.dart';

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

Future<RoutineTemplateDto?> runFunctionMessage(
    {required String system, required String user, required BuildContext context}) async {
  RoutineTemplateDto? templateDto;

  final response = await runMessageWithFunctionCall(system: system, user: user);
  if (response != null) {
    final choices = response;
    if (choices.isNotEmpty) {
      final choice = choices[0];
      final toolCalls = choice['message']['tool_calls'] as List<dynamic>;
      if (toolCalls.isNotEmpty) {
        final tool = toolCalls[0];
        final function = tool['function']['name'];
        if (function == "list_exercises") {
          if (context.mounted) {
            final exercises = Provider.of<ExerciseController>(context, listen: false).exercises;
            final listOfExerciseJsons = exercises
                .map((exercise) => jsonEncode({
                      "id": exercise.id,
                      "name": exercise.name,
                      "primary_muscle_group": exercise.primaryMuscleGroup.name,
                      "secondary_muscle_groups":
                          exercise.secondaryMuscleGroups.map((muscleGroup) => muscleGroup.name).toList()
                    }))
                .toList();

            final functionCallMessage = {
              "role": "assistant",
              "tool_calls": [
                {
                  "id": tool["id"],
                  "type": "function",
                  "function": {"arguments": "{}", "name": "list_exercises"}
                }
              ]
            };

            final functionCallResultMessage = {
              "role": "tool",
              "content": jsonEncode({
                "exercises": listOfExerciseJsons,
              }),
              "tool_call_id": tool["id"]
            };

            final payload = jsonEncode({
              "model": "gpt-4o-mini",
              "messages": [
                {"role": "system", "content": defaultSystemInstruction},
                {"role": "user", "content": user},
                functionCallMessage,
                functionCallResultMessage
              ],
              "response_format": exercisesResponseFormat
            });

            final jsonString = await runMessageWithFunctionCallResult(payload: payload);
            if (jsonString != null) {
              final json = jsonDecode(jsonString);
              final exerciseIds = json["exercises"] as List<dynamic>;
              final workoutName = json["workout_name"] ?? "A workout";
              final workoutCaption = json["workout_caption"] ?? "A workout created by TRKR Coach";
              final exerciseTemplates = exerciseIds.map((exerciseId) {
                final exerciseInLibrary = exercises.firstWhere((exercise) => exercise.id == exerciseId);
                final exerciseTemplate = ExerciseLogDto(exerciseInLibrary.id, "", "", exerciseInLibrary, "",
                    [const SetDto(0, 0, false)], DateTime.now(), []);
                return exerciseTemplate;
              }).toList();
              templateDto = RoutineTemplateDto(
                  id: "",
                  name: workoutName,
                  exerciseTemplates: exerciseTemplates,
                  notes: workoutCaption,
                  owner: SharedPrefs().userId,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now());
            }
          }
        }
      }
    }
  }
  return templateDto;
}

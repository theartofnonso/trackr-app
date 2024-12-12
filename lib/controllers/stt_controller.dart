import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:tracker_app/enums/exercise_logging_function.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/enums/open_ai_models.dart';

import '../dtos/open_ai_response_schema_dtos/reps.dart';
import '../dtos/open_ai_response_schema_dtos/tool_dto.dart';
import '../dtos/open_ai_response_schema_dtos/weight_and_reps.dart';
import '../dtos/set_dtos/reps_dto.dart';
import '../dtos/set_dtos/set_dto.dart';
import '../dtos/set_dtos/weight_and_reps_dto.dart';
import '../openAI/open_ai.dart';
import '../openAI/open_ai_response_format.dart';
import '../strings/ai_prompts.dart';
import '../utils/exercise_logs_utils.dart';

/// Represents the overall state of the STT controller.
enum STTState {
  notListening,
  listening,
  analysing,
  done,
  noPermission,
  error;

  static STTState fromString(String string) {
    return STTState.values.firstWhere((value) => value.name.toLowerCase() == string.toLowerCase(), orElse: () {
      return string == "error" ? STTState.error : STTState.analysing;
    });
  }
}

class STTController extends ChangeNotifier {

  STTState _state = STTState.notListening;
  List<SetDto> _sets = [];

  STTState get state => _state;

  List<SetDto> get sets => List.unmodifiable(_sets);

  ExerciseType _exerciseType = ExerciseType.weights;

  final _record = AudioRecorder();

  String? _recordedFilePath;

  /// Initializes the speech recognition service.
  Future<void> initialize({required ExerciseType exerciseType, required List<SetDto> initialSets}) async {
    _exerciseType = exerciseType;
    _sets = initialSets;
    notifyListeners();
  }

  /// Start listening for user speech input.
  Future<void> startListening() async {
    // Check for permissions
    if (await _record.hasPermission()) {
      // Get a directory to store the recording
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/myFile.m4a';

      // Start recording to a file
      await _record.start(
        const RecordConfig(),
        path: filePath,
      );

      _recordedFilePath = filePath;

      _setState(STTState.listening);
    } else {
      _setState(STTState.noPermission);
    }
  }

  /// Stop listening for user speech input.
  Future<void> stopListening() async {
    if (_state == STTState.notListening) return;

    // Stop the recording
    final path = await _record.stop();

    _setState(STTState.notListening);

    // path should match _recordedFilePath if successful
    // Now we have a recorded audio file at `path`

    // Call _analyse with the recorded file path
    if (path != null && File(path).existsSync()) {
      await _analyseAudio();
    }

    await _record.dispose();
  }

  /// Reset the internal state and recognized sets.
  void reset() async {
    _sets.clear();
    _recordedFilePath = "";
    _recordedFilePath = null;
    await _record.cancel();
    await _record.dispose();
    _setState(STTState.notListening);
  }

  Future<void> _analyseAudio() async {
    final recordedFilePath = _recordedFilePath;

    final file = File(recordedFilePath ?? "");

    // Make sure the file exists
    if (!file.existsSync()) {
      return;
    }

    _setState(STTState.analysing);

    final url = Uri.https("api.openai.com", "/v1/audio/transcriptions");
    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $apiKey';
    request.fields['model'] = OpenAIModel.whisper.name;
    request.files.add(await http.MultipartFile.fromPath("file", file.path));

    try {
      // Send the request
      final response = await request.send();

      // Parse the response
      if (response.statusCode == 200) {
        // Successful upload
        final responseBody = await http.Response.fromStream(response);
        final userPrompt = jsonDecode(responseBody.body)["text"];

        final jsonToCallTool = await runMessageWithTools(
          systemInstruction: personalTrainerInstructionForWorkoutLogging,
          userInstruction: userPrompt,
        );

        if (jsonToCallTool == null) {
          _setState(STTState.error);
          return;
        }

        final tool = ToolDto.fromJson(jsonToCallTool);

        final function = ExerciseLoggingFunction.fromString(tool.name);
        switch (function) {
          case ExerciseLoggingFunction.addSet:
            _addSet(tool: tool, userInstruction: userPrompt);
            break;
          case ExerciseLoggingFunction.removeSet:
            _updateSets(
                tool: tool,
                systemInstruction: removeSetInstruction,
                userInstruction: userPrompt,
                function: ExerciseLoggingFunction.removeSet);
            break;
          case ExerciseLoggingFunction.updateSet:
            _updateSets(
                tool: tool,
                systemInstruction: updateSetInstruction,
                userInstruction: userPrompt,
                function: ExerciseLoggingFunction.updateSet);
            break;
        }
      } else {
        _setState(STTState.error);
      }
    } catch (e) {
      _setState(STTState.error);
    }
  }

  Future<void> _addSet({required ToolDto tool, required String userInstruction}) async {
    final responseFormat = withWeightsOnly(type: _exerciseType) ? weightAndRepsResponseFormat : repsResponseFormat;

    final functionCallPayload = createFunctionCallPayload(
        tool: tool,
        systemInstruction: addSetInstruction,
        user: userInstruction,
        responseFormat: responseFormat,
        functionName: ExerciseLoggingFunction.addSet.name,
        extra: userInstruction);

    try {
      final functionCallResult = await runMessageWithFunctionCallPayload(payload: functionCallPayload);

      if (functionCallResult == null) {
        _setState(STTState.error);
        return;
      }

      // Deserialize the JSON string
      Map<String, dynamic> json = jsonDecode(functionCallResult);

      switch (_exerciseType) {
        case ExerciseType.weights:
          final set = WeightAndReps.toDto(json, checked: true);
          _sets.add(set);
          break;
        case ExerciseType.bodyWeight:
          final set = Reps.toDto(json, checked: true);
          _sets.add(set);
        case ExerciseType.duration:
        // TODO: Handle this case.
      }

      _setState(STTState.notListening);
    } catch (e) {
      _setState(STTState.error);
    }
  }

  Future<void> _updateSets(
      {required ToolDto tool,
      required String systemInstruction,
      required String userInstruction,
      required ExerciseLoggingFunction function}) async {
    final listOfSetsJsons = {
      "sets": _sets.map((set) {
        return switch (set.type) {
          ExerciseType.weights => {
              "weight": (set as WeightAndRepsSetDto).weight,
              "repetitions": set.reps,
            },
          ExerciseType.bodyWeight => {
              "repetitions": (set as RepsSetDto).reps,
            },
          ExerciseType.duration => throw UnimplementedError(),
        };
      }).toList(),
    };

    final responseFormat =
        withWeightsOnly(type: _exerciseType) ? weightAndRepsListResponseFormat : repsListResponseFormat;

    final functionCallPayload = createFunctionCallPayload(
        tool: tool,
        systemInstruction: systemInstruction,
        user: userInstruction,
        responseFormat: responseFormat,
        functionName: function.name,
        extra: jsonEncode(listOfSetsJsons));

    try {
      final functionCallResult = await runMessageWithFunctionCallPayload(payload: functionCallPayload);

      if (functionCallResult == null) {
        _setState(STTState.error);
        return;
      }

      // Deserialize the JSON string
      Map<String, dynamic> json = jsonDecode(functionCallResult);
      final setsInJson = json["sets"] as List<dynamic>;

      switch (_exerciseType) {
        case ExerciseType.weights:
          _sets = setsInJson.map((json) => WeightAndReps.toDto(json, checked: true)).toList();
          break;
        case ExerciseType.bodyWeight:
          _sets = setsInJson.map((json) => Reps.toDto(json, checked: true)).toList();
          break;
        case ExerciseType.duration:
        // TODO: Handle this case.
      }

      _setState(STTState.notListening);
    } catch (e) {
      _setState(STTState.error);
    }
  }

  /// Helper to update the state and notify listeners.
  void _setState(STTState newState) {
    _state = newState;
    notifyListeners();
  }
}

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart';
import 'package:tracker_app/enums/exercise_logging_function.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';

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
  error;

  static STTState fromString(String string) {
    return STTState.values.firstWhere((value) => value.name.toLowerCase() == string.toLowerCase(), orElse: () {
      return string == "error" ? STTState.error : STTState.analysing;
    });
  }
}

class STTController extends ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _speechAvailable = false;
  STTState _state = STTState.notListening;
  List<SetDto> _sets = [];

  bool get speechAvailable => _speechAvailable;

  STTState get state => _state;

  List<SetDto> get sets => List.unmodifiable(_sets);

  /// Initializes the speech recognition service.
  Future<void> initialize({required List<SetDto> initialSets}) async {
    if (!_speechAvailable) {
      _speechAvailable = await _speech.initialize(
        onError: _onSpeechError,
      );
    }
    _sets = initialSets;
    notifyListeners();
  }

  /// Start listening for user speech input.
  Future<void> startListening({required ExerciseType exerciseType}) async {
    if (!_speechAvailable) return;
    _setState(STTState.listening);
    await _speech.listen(
      listenFor: const Duration(seconds: 5),
      onResult: (result) => _onSpeechResult(exerciseType: exerciseType, result: result),
      listenOptions: SpeechListenOptions(listenMode: stt.ListenMode.dictation),
    );
  }

  /// Reset the internal state and recognized sets.
  void reset() {
    _sets.clear();
    closeSpeech();
  }

  void closeSpeech() {
    _speech.cancel();
    _speech.stop();
  }

  /// Internal callback when speech recognition receives partial or final results.
  void _onSpeechResult({required ExerciseType exerciseType, required SpeechRecognitionResult result}) {
    final recognizedWords = result.recognizedWords;
    if (result.finalResult && recognizedWords.isNotEmpty) {
      _analyse(userPrompt: recognizedWords, exerciseType: exerciseType);
    }
  }

  /// Internal callback if an error occurs during speech recognition.
  void _onSpeechError(SpeechRecognitionError errorNotification) {
    _setState(STTState.error);
  }

  Future<void> _analyse({required String userPrompt, required ExerciseType exerciseType}) async {
    _setState(STTState.analysing);

    final json = await runMessageWithTools(
      systemInstruction: personalTrainerInstructionForWorkoutLogging,
      userInstruction: userPrompt,
    );

    if (json == null) {
      _setState(STTState.error);
      return;
    }

    final tool = ToolDto.fromJson(json);

    final function = ExerciseLoggingFunction.fromString(tool.name);
    switch (function) {
      case ExerciseLoggingFunction.addSet:
        _addSet(
            tool: tool, userInstruction: userPrompt, exerciseType: exerciseType);
        break;
      case ExerciseLoggingFunction.removeSet:
        _updateSets(
            tool: tool,
            systemInstruction: removeSetInstruction,
            userInstruction: userPrompt,
            exerciseType: exerciseType,
            function: ExerciseLoggingFunction.removeSet);
        break;
      case ExerciseLoggingFunction.updateSet:
        _updateSets(
            tool: tool,
            systemInstruction: updateSetInstruction,
            userInstruction: userPrompt,
            exerciseType: exerciseType,
            function: ExerciseLoggingFunction.updateSet);
        break;
    }
  }

  Future<void> _addSet(
      {required ToolDto tool,
      required String userInstruction,
      required ExerciseType exerciseType}) async {
    final responseFormat = withWeightsOnly(type: exerciseType) ? weightAndRepsResponseFormat : repsResponseFormat;

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

      switch (exerciseType) {
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
      required ExerciseLoggingFunction function,
      required ExerciseType exerciseType}) async {
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
        withWeightsOnly(type: exerciseType) ? weightAndRepsListResponseFormat : repsListResponseFormat;

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

      switch (exerciseType) {
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

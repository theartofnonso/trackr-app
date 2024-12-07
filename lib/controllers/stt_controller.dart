import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart';
import 'package:tracker_app/enums/exercise_logging_function.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';

import '../dtos/open_ai_response_schema_dtos/reps_set_intent.dart';
import '../dtos/open_ai_response_schema_dtos/tool_dto.dart';
import '../dtos/open_ai_response_schema_dtos/weights_and_reps_set_intent.dart';
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
  final List<SetDto> _sets = [];

  bool get speechAvailable => _speechAvailable;

  STTState get state => _state;

  List<SetDto> get sets => List.unmodifiable(_sets);

  /// Initializes the speech recognition service.
  Future<void> initialize() async {
    if (!_speechAvailable) {
      _speechAvailable = await _speech.initialize(
        onError: _onSpeechError,
      );
    }
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
    _speech.cancel();
    _speech.stop();
  }

  /// Internal callback when speech recognition receives partial or final results.
  void _onSpeechResult({required ExerciseType exerciseType, required SpeechRecognitionResult result}) {
    final recognizedWords = result.recognizedWords;
    if (result.finalResult && recognizedWords.isNotEmpty) {
      //_analyseIntent(userPrompt: recognizedWords, exerciseType: exerciseType);
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
      systemInstruction: personalTrainerInstructionForWorkouts,
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
        final responseFormat =
            withWeightsOnly(type: exerciseType) ? logWeightAndRepsIntentResponseFormat : logRepsIntentResponseFormat;
        final systemInstructions =
            withWeightsOnly(type: exerciseType) ? weightAndRepsLoggingContext : repetitionsLoggingContext;

        _addSet(
            tool: tool,
            systemInstruction: systemInstructions,
            responseFormat: responseFormat,
            userInstruction: userPrompt,
            exerciseType: exerciseType);
        break;
      case ExerciseLoggingFunction.removeSet:
      // Call function to remove set
      case ExerciseLoggingFunction.updateSet:
      // Call function to update set
    }
  }

  Future<void> _addSet(
      {required ToolDto tool,
      required String systemInstruction,
      required Map<String, Object> responseFormat,
      required String userInstruction,
      required ExerciseType exerciseType}) async {
    final functionCallPayload = createFunctionCallPayload(
        tool: tool,
        systemInstruction: systemInstruction,
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

      final isWithWeights = withWeightsOnly(type: exerciseType);

      if (isWithWeights) {
        final intent = WeightsAndRepsSetIntent.fromJson(json);
        _sets.add(WeightAndRepsSetDto(
          weight: intent.weight,
          reps: intent.repetitions,
          checked: true,
        ));
      } else {
        final intent = RepsSetIntent.fromJson(json);
        _sets.add(RepsSetDto(
          reps: intent.repetitions,
          checked: true,
        ));
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

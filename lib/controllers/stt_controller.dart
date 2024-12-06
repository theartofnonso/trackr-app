import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';

import '../dtos/open_ai_response_schema_dtos/reps_set_intent.dart';
import '../dtos/open_ai_response_schema_dtos/weights_and_reps_set_intent.dart';
import '../dtos/set_dtos/reps_dto.dart';
import '../dtos/set_dtos/set_dto.dart';
import '../dtos/set_dtos/weight_and_reps_dto.dart';
import '../openAI/open_ai.dart';
import '../openAI/open_ai_functions.dart';
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
  String _recognizedWords = "";

  bool get speechAvailable => _speechAvailable;

  STTState get state => _state;

  List<SetDto> get sets => List.unmodifiable(_sets);

  /// Initializes the speech recognition service.
  Future<void> initialize() async {
    if (!_speechAvailable) {
      _speechAvailable = await _speech.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
      );
    }
  }

  /// Start listening for user speech input.
  Future<void> startListening() async {
    if (!_speechAvailable) return;
    await _speech.listen(
      listenFor: const Duration(seconds: 5),
      onResult: _onSpeechResult,
      listenOptions: SpeechListenOptions(listenMode: stt.ListenMode.dictation),
    );
  }

  /// Reset the internal state and recognized sets.
  void reset() {
    _sets.clear();
    _recognizedWords = "";
    _speech.cancel();
    _speech.stop();
  }

  /// Internal callback when speech recognition receives partial or final results.
  void _onSpeechResult(SpeechRecognitionResult result) {
    _recognizedWords = result.recognizedWords;
  }

  /// Internal callback when speech recognition status changes.
  void _onSpeechStatus(String string) {
    // The possible statuses are: "done", "listening", "notListening"
    // When done, we begin analysis of the recognized words.
    final status = STTState.fromString(string);
    if (status == STTState.done) {
      print(string);
      _setState(STTState.analysing);
      _analyseIntent(userPrompt: _recognizedWords);
    } else {
      _setState(status);
    }
  }

  /// Internal callback if an error occurs during speech recognition.
  void _onSpeechError(SpeechRecognitionError errorNotification) {
    _setState(STTState.error);
  }

  /// Analyse the recognized words using OpenAI to determine the user's intent.
  Future<void> _analyseIntent({required String userPrompt}) async {

    // In a real scenario, you'd determine the exerciseType from context or passed data.
    final exerciseType = ExerciseType.weights;
    final isWithWeights = withWeightsOnly(type: exerciseType);

    final responseFormat = isWithWeights ? logWeightAndRepsIntentResponseFormat : logRepsIntentResponseFormat;
    final systemInstructions = isWithWeights ? weightAndRepsLoggingContext : repetitionsLoggingContext;

    try {
      final response = await runMessage(
        system: systemInstructions,
        user: userPrompt,
        responseFormat: responseFormat,
      );

      if (response == null) {
        throw Exception("No response from AI");
      }

      final jsonResponse = jsonDecode(response) as Map<String, dynamic>;

      if (isWithWeights) {
        final intent = WeightsAndRepsSetIntent.fromJson(jsonResponse);
        _sets.add(WeightAndRepsSetDto(
          weight: intent.weight,
          reps: intent.repetitions,
          checked: true,
        ));
      } else {
        final intent = RepsSetIntent.fromJson(jsonResponse);
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

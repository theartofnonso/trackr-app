import 'dart:convert';

import 'package:flutter/foundation.dart';
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

enum STTListeningStatus {
  listening,
  notListening,
  done;

  static STTListeningStatus fromString(String string) {
    return STTListeningStatus.values.firstWhere((value) => value.name.toLowerCase() == string.toLowerCase());
  }
}

class STTController extends ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _speechAvailable = false;
  STTListeningStatus _listeningStatus = STTListeningStatus.notListening;
  List<SetDto> _sets = [];
  bool _hasErrors = false;
  bool _isAnalysing = false;
  String _recognizedWords = "";

  bool get speechAvailable => _speechAvailable;

  List<SetDto> get sets => _sets;

  STTListeningStatus get listeningStatus => _listeningStatus;

  bool get hasErrors => _hasErrors;

  bool get isAnalysing => _isAnalysing;

  Future<void> initialize() async {
    if (!_speechAvailable) {
      _speechAvailable = await _speech.initialize(
        onStatus: (status) {
          _listeningStatus = STTListeningStatus.fromString(status);
          if (_listeningStatus == STTListeningStatus.done) {
            _analyseIntent(userPrompt: _recognizedWords);
          }
          notifyListeners();
        },
        onError: (errorNotification) {
          _hasErrors = true;
          _listeningStatus = STTListeningStatus.notListening;
          _isAnalysing = false;
          notifyListeners();
        },
      );
    }
  }

  Future<void> listen() async {
    if (_speechAvailable) {
      print("Start Listening");
      await _speech.listen(
        listenOptions: SpeechListenOptions(listenMode: stt.ListenMode.dictation),
        listenFor: const Duration(seconds: 5),
        onResult: (result) {
          _recognizedWords = result.recognizedWords;
          print("Found some words");
        },
      );
    }
  }

  void _analyseIntent({required String userPrompt}) {
    final exerciseType = ExerciseType.weights;
    final responseFormat = withWeightsOnly(type: exerciseType) ? logWeightAndRepsIntentResponseFormat : logRepsIntentResponseFormat;
    final systemInstructions = withWeightsOnly(type: exerciseType) ? weightAndRepsLoggingContext : repetitionsLoggingContext;

    runMessage(
      system: systemInstructions,
      user: userPrompt,
      responseFormat: responseFormat,
    ).then((response) {
      _hasErrors = false;
      if (response != null) {
        // Deserialize the JSON string
        Map<String, dynamic> json = jsonDecode(response);

        // Create an instance of the appropriate SetDto
        if (withWeightsOnly(type: exerciseType)) {
          WeightsAndRepsSetIntent intent = WeightsAndRepsSetIntent.fromJson(json);
          final set = WeightAndRepsSetDto(
            weight: intent.weight,
            reps: intent.repetitions,
            checked: true,
          );
          _sets.add(set);
          notifyListeners();
        } else if (withRepsOnly(type: exerciseType)) {
          RepsSetIntent intent = RepsSetIntent.fromJson(json);
          final set = RepsSetDto(
            reps: intent.repetitions,
            checked: true,
          );
          _sets.add(set);
          notifyListeners();
        }
      }
    }).catchError((e) {
      _hasErrors = true;
      notifyListeners();
    });
  }

  void stopAnalysing() {
    _isAnalysing = false;
    notifyListeners();
  }

  void reset() {
    _sets = [];
    _isAnalysing = false;
    _hasErrors = false;
    notifyListeners();
  }
}

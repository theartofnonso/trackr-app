import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/dtos/open_ai_response_schema_dtos/weights_and_reps_set_intent.dart';
import 'package:tracker_app/dtos/set_dtos/set_dto.dart';
import 'package:tracker_app/dtos/set_dtos/weight_and_reps_dto.dart';
import 'package:tracker_app/openAI/open_ai_functions.dart';
import 'package:tracker_app/utils/exercise_logs_utils.dart';
import 'package:tracker_app/utils/general_utils.dart';
import 'package:tracker_app/widgets/routine/preview/set_headers/double_set_header.dart';
import 'package:tracker_app/widgets/routine/preview/set_rows/single_set_row.dart';

import '../../colors.dart';
import '../../dtos/open_ai_response_schema_dtos/reps_set_intent.dart';
import '../../dtos/set_dtos/reps_dto.dart';
import '../../openAI/open_ai.dart';
import '../../strings/ai_prompts.dart';
import '../../utils/dialog_utils.dart';
import '../../widgets/ai_widgets/trkr_coach_widget.dart';
import '../../widgets/backgrounds/trkr_loading_screen.dart';
import '../../widgets/routine/preview/set_rows/double_set_row.dart';

class STTLoggingScreen extends StatefulWidget {
  final ExerciseLogDto exerciseLog;

  const STTLoggingScreen({super.key, required this.exerciseLog});

  @override
  State<STTLoggingScreen> createState() => _STTLoggingScreenState();
}

class _STTLoggingScreenState extends State<STTLoggingScreen> {
  late stt.SpeechToText _speech;

  bool _isListening = false;

  String _userPrompt = "";

  bool _loading = false;

  List<SetDto> _sets = [];

  @override
  Widget build(BuildContext context) {
    if (_loading) return TRKRLoadingScreen(action: _hideLoadingScreen);

    final exerciseType = widget.exerciseLog.exercise.type;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: sapphireDark80,
          title: Text("Logging ${widget.exerciseLog.exercise.name}".toUpperCase(),
              style: GoogleFonts.ubuntu(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
          leading: IconButton(
              icon: const FaIcon(FontAwesomeIcons.solidSquareCheck, color: Colors.white, size: 28),
              onPressed: Navigator.of(context).pop),
          actions: [
            if (_sets.isNotEmpty)
              IconButton(
                onPressed: _navigateBack,
                icon: FaIcon(
                  FontAwesomeIcons.squareCheck,
                ),
              )
          ],
        ),
        floatingActionButton: FloatingActionButton(
            heroTag: "routine_log_screen",
            onPressed: _startListening,
            backgroundColor: sapphireDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: FaIcon(FontAwesomeIcons.microphone, color: _isListening ? vibrantGreen : Colors.white)),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                sapphireDark80,
                sapphireDark,
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final set = _sets[index];
                  if (withWeightsOnly(type: exerciseType)) {
                    final weightAndRepsSet = set as WeightAndRepsSetDto;
                    return ListTile(
                      leading: TRKRCoachWidget(),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DoubleSetHeader(firstLabel: weightLabel().toUpperCase(), secondLabel: "REPS"),
                          const SizedBox(height: 6),
                          DoubleSetRow(
                              first: '${weightAndRepsSet.weight}${weightLabel()}', second: '${weightAndRepsSet.reps}'),
                        ],
                      ),
                    );
                  }
                  return ListTile(
                      leading: TRKRCoachWidget(),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SingleSetRow(label: "Reps".toUpperCase()),
                          const SizedBox(height: 6),
                          SingleSetRow(label: "${(set as RepsSetDto).reps}"),
                        ],
                      ));
                },
                separatorBuilder: (context, index) => SizedBox(height: 12),
                itemCount: _sets.length),
          ),
        ));
  }

  Future<void> _startListening() async {
    await HapticFeedback.heavyImpact();
    _speech.listen(
        listenOptions: SpeechListenOptions(listenMode: stt.ListenMode.dictation),
        listenFor: Duration(seconds: 3),
        onResult: (result) {
          _userPrompt = result.recognizedWords;
        });
  }

  void _navigateBack() {
    if (_sets.isNotEmpty) {
      Navigator.of(context).pop(_sets);
    }
  }

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _speech.initialize(onStatus: (status) {
      print(status);
      setState(() {
        _isListening = status == "listening";
      });

      if (status == "done") {
        if (!_loading) {
          _showLoadingScreen();
          _analyseIntent();
        }
      }
    }, onError: (_) {
      showSnackbar(
          context: context,
          icon: FaIcon(FontAwesomeIcons.circleInfo),
          message: "Oops! Unable to initialise speech listener");
    });
  }

  void _showLoadingScreen() {
    setState(() {
      _loading = true;
    });
  }

  void _hideLoadingScreen() {
    setState(() {
      _loading = false;
    });
  }

  void _analyseIntent() {
    final exerciseType = widget.exerciseLog.exercise.type;
    final responseFormat =
        withWeightsOnly(type: exerciseType) ? logWeightAndRepsIntentResponseFormat : logRepsIntentResponseFormat;
    final systemInstructions =
        withWeightsOnly(type: exerciseType) ? weightAndRepsLoggingContext : repetitionsLoggingContext;
    runMessage(system: systemInstructions, user: _userPrompt, responseFormat: responseFormat).then((response) {
      _hideLoadingScreen();
      if (response != null) {
        if (mounted) {
          // Deserialize the JSON string
          Map<String, dynamic> json = jsonDecode(response);

          // Create an instance of ExerciseLogsResponse
          if (withWeightsOnly(type: exerciseType)) {
            WeightsAndRepsSetIntent intent = WeightsAndRepsSetIntent.fromJson(json);
            final set = WeightAndRepsSetDto(weight: intent.weight, reps: intent.repetitions, checked: true);
            _sets.add(set);
            print("Log weight: ${intent.weight}, repetitions: ${intent.repetitions}");
          }

          if (withRepsOnly(type: exerciseType)) {
            RepsSetIntent intent = RepsSetIntent.fromJson(json);
            final set = RepsSetDto(reps: intent.repetitions, checked: true);
            _sets.add(set);
            print("Log repetitions: ${intent.repetitions}");
          }
        }
      }
    }).catchError((e) {
      _hideLoadingScreen();
      if (mounted) {
        showSnackbar(
            context: context, icon: TRKRCoachWidget(), message: "Oops! I am unable to understand your request");
      }
    });
  }

  void _disposeContext() {
    _speech.stop();
    _sets = [];
    print("c");
  }

  @override
  void dispose() {
    _disposeContext();
    super.dispose();
  }
}

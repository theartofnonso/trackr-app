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
import 'package:tracker_app/widgets/empty_states/no_list_empty_state.dart';
import 'package:tracker_app/widgets/routine/preview/exercise_log_widget.dart';

import '../../colors.dart';
import '../../dtos/open_ai_response_schema_dtos/reps_set_intent.dart';
import '../../dtos/set_dtos/reps_dto.dart';
import '../../openAI/open_ai.dart';
import '../../strings/ai_prompts.dart';
import '../../utils/dialog_utils.dart';
import '../../widgets/ai_widgets/trkr_coach_widget.dart';
import '../../widgets/backgrounds/trkr_loading_screen.dart';

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

    final exerciseLog = widget.exerciseLog.copyWith(sets: _sets);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: sapphireDark80,
          title: Text("Logging ${widget.exerciseLog.exercise.name}".toUpperCase(),
              style: GoogleFonts.ubuntu(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
          leading: IconButton(
              icon: const FaIcon(FontAwesomeIcons.squareXmark, color: Colors.white, size: 28),
              onPressed: Navigator.of(context).pop),
          actions: [
            if (_sets.isNotEmpty)
              IconButton(
                onPressed: _navigateBack,
                icon: FaIcon(
                  FontAwesomeIcons.solidSquareCheck,
                ),
              )
          ],
        ),
        floatingActionButton: FloatingActionButton(
            heroTag: "routine_log_screen",
            onPressed: _startListening,
            backgroundColor: _isListening ? vibrantGreen : sapphireDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: FaIcon(FontAwesomeIcons.microphone, color: _isListening ? Colors.black : Colors.white)),
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
            minimum: const EdgeInsets.all(10.0),
            child: _sets.isNotEmpty
                ? Column(
                    children: [_HeroWidget(), const SizedBox(height: 10), ExerciseLogWidget(exerciseLog: exerciseLog)],
                  )
                : NoListEmptyState(message: "It might feel quiet now, but your logged sets will soon appear here.."),
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
          }

          if (withRepsOnly(type: exerciseType)) {
            RepsSetIntent intent = RepsSetIntent.fromJson(json);
            final set = RepsSetDto(reps: intent.repetitions, checked: true);
            _sets.add(set);
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
  }

  @override
  void dispose() {
    _disposeContext();
    super.dispose();
  }
}

class _HeroWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const TRKRCoachWidget(),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            RichText(
              text: TextSpan(
                text: "Hey there!",
                style: GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white, height: 1.5),
                children: <TextSpan>[
                  TextSpan(
                      text: " ",
                      style: GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white)),
                  TextSpan(
                      text: "TRKR Coach",
                      style: GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                  TextSpan(
                      text: " ",
                      style: GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white)),
                  TextSpan(
                      text: "can help you create awesome workouts",
                      style: GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white)),
                  TextSpan(
                      text: ".",
                      style: GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white)),
                  TextSpan(
                      text: " ",
                      style: GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white)),
                  TextSpan(
                      text: "Try saying",
                      style: GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white)),
                  TextSpan(
                      text: " ",
                      style: GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white)),
                  TextSpan(
                      text: 'I want to train "mention muscle group(s)"',
                      style: GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                ],
              ),
            )
          ]),
        )
      ]),
    );
  }
}

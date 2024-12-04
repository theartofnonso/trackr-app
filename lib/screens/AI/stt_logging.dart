import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';

import '../../colors.dart';
import '../../utils/dialog_utils.dart';

class STTLogging extends StatefulWidget {

  final ExerciseLogDto exerciseLog;

  const STTLogging({super.key, required this.exerciseLog});

  @override
  State<STTLogging> createState() => _STTLoggingState();
}

class _STTLoggingState extends State<STTLogging> {
  late stt.SpeechToText _speech;

  bool _isListening = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: sapphireDark80,
          title: Text("Logging ${widget.exerciseLog.exercise.name}".toUpperCase(),
              style: GoogleFonts.ubuntu(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
          leading: IconButton(
              icon: const FaIcon(FontAwesomeIcons.squareXmark, color: Colors.white, size: 28),
              onPressed: Navigator.of(context).pop),
        ),
        body: Container(
          width: double.infinity,
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
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _startListening,
                    icon: FaIcon(
                      FontAwesomeIcons.microphone,
                      color: _isListening ? vibrantGreen : Colors.white,
                      size: 48,
                    ),
                  )
                ]),
          ),
        ));
  }

  Future<void> _startListening() async {
    await HapticFeedback.heavyImpact();
    _speech.listen(
        listenOptions: SpeechListenOptions(listenMode: stt.ListenMode.dictation),
        listenFor: Duration(seconds: 5),
        onResult: (result) {
          print(result.recognizedWords);
        });
  }

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _speech.initialize(onStatus: (status) {
      setState(() {
        _isListening = status == "listening";
      });

     if(status == "done") {
       print("Sending command to OpenAI");
     }
    }, onError: (_) {
      showSnackbar(
          context: context,
          icon: FaIcon(FontAwesomeIcons.circleInfo),
          message: "Oops! Unable to initialise speech listener");
    });
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }
}

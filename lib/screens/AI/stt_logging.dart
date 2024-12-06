import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/dtos/set_dtos/set_dto.dart';
import 'package:tracker_app/widgets/routine/preview/exercise_log_widget.dart';

import '../../colors.dart';
import '../../controllers/stt_controller.dart';
import '../../widgets/ai_widgets/trkr_coach_widget.dart';
import '../../widgets/backgrounds/trkr_loading_screen.dart';

class STTLoggingScreen extends StatefulWidget {
  final ExerciseLogDto exerciseLog;

  const STTLoggingScreen({super.key, required this.exerciseLog});

  @override
  State<STTLoggingScreen> createState() => _STTLoggingScreenState();
}

class _STTLoggingScreenState extends State<STTLoggingScreen> {
  List<SetDto> _sets = [];

  @override
  void initState() {
    super.initState();
    context.read<STTController>().initialize();
    _sets = widget.exerciseLog.sets.where((set) => set.isNotEmpty()).toList();
  }


  @override
  void dispose() {
    super.dispose();
    context.read<STTController>().reset();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //_sets = widget.exerciseLog.sets.where((set) => set.isNotEmpty()).toList();
  }

  @override
  Widget build(BuildContext context) {
    final sttController = context.watch<STTController>();

    final exerciseLog = widget.exerciseLog.copyWith(sets: sttController.sets);

    if (sttController.isAnalysing) return TRKRLoadingScreen(action: _hideLoadingScreen);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: sapphireDark80,
        title: Text(
          "Logging ${widget.exerciseLog.exercise.name}".toUpperCase(),
          style: GoogleFonts.ubuntu(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.squareXmark,
            color: Colors.white,
            size: 28,
          ),
          onPressed: Navigator.of(context).pop,
        ),
        actions: [
          if (sttController.sets.isNotEmpty)
            IconButton(
              onPressed: _navigateBack,
              icon: const FaIcon(
                FontAwesomeIcons.solidSquareCheck,
              ),
            )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "routine_log_screen",
        onPressed: () => _startListening(),
        backgroundColor: sttController.listeningStatus == STTListeningStatus.listening ? vibrantGreen : sapphireDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: FaIcon(
          FontAwesomeIcons.microphone,
          color: sttController.listeningStatus == STTListeningStatus.listening ? Colors.black : Colors.white,
        ),
      ),
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                _HeroWidget(),
                const SizedBox(height: 10),
                ExerciseLogWidget(exerciseLog: exerciseLog),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _startListening() async {
    await HapticFeedback.heavyImpact();
    if (mounted) {
      context.read<STTController>().listen();
    }
  }

  void _navigateBack() {
    if (_sets.isNotEmpty) {
      Navigator.of(context).pop(_sets);
      context.read<STTController>().reset();
    }
  }

  void _hideLoadingScreen() {
    context.read<STTController>().stopAnalysing();
  }
}

class _HeroWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TRKRCoachWidget(),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: "Hey there!",
                style: GoogleFonts.ubuntu(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  height: 1.5,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: " ",
                    style: GoogleFonts.ubuntu(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(
                    text: "TRKR Coach",
                    style: GoogleFonts.ubuntu(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(
                    text: " can help you log sets with your voice only.",
                    style: GoogleFonts.ubuntu(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(
                    text: " Try saying ",
                    style: GoogleFonts.ubuntu(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(
                    text: 'Log 25kg for 10 reps',
                    style: GoogleFonts.ubuntu(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

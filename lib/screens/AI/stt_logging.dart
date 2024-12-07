import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/controllers/exercise_and_routine_controller.dart';
import 'package:tracker_app/controllers/stt_controller.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/widgets/ai_widgets/trkr_coach_widget.dart';
import 'package:tracker_app/widgets/dividers/label_container_divider.dart';
import 'package:tracker_app/widgets/routine/preview/sets_listview.dart';

import '../../widgets/backgrounds/trkr_loading_screen.dart';

class STTLoggingScreen extends StatefulWidget {
  final ExerciseLogDto exerciseLog;

  const STTLoggingScreen({super.key, required this.exerciseLog});

  @override
  State<STTLoggingScreen> createState() => _STTLoggingScreenState();
}

class _STTLoggingScreenState extends State<STTLoggingScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize speech recognition when the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<STTController>().initialize();
    });
  }

  void _reset() {
    context.read<STTController>().reset();
  }

  @override
  Widget build(BuildContext context) {
    final sttController = context.watch<STTController>();

    if (sttController.state == STTState.analysing) return TRKRLoadingScreen();

    // Updated ExerciseLog with the recognized sets.
    final updatedExerciseLog = widget.exerciseLog.copyWith(sets: sttController.sets);

    final previousSets = Provider.of<ExerciseAndRoutineController>(context, listen: false)
        .whereSetsForExercise(exercise: widget.exerciseLog.exercise);

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
          onPressed: () {
            _reset();
            Navigator.of(context).pop();
          },
        ),
        actions: [
          if (sttController.sets.isNotEmpty)
            IconButton(
              onPressed: () {
                final sets = [...sttController.sets];
                _reset();
                Navigator.of(context).pop(sets);
              },
              icon: const FaIcon(
                FontAwesomeIcons.solidSquareCheck,
              ),
            )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "stt_log_screen",
        onPressed: _onMicPressed,
        backgroundColor: sttController.state == STTState.listening ? vibrantGreen : sapphireDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: FaIcon(
          FontAwesomeIcons.microphone,
          color: sttController.state == STTState.listening ? Colors.black : Colors.white,
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
                const SizedBox(height: 20),
                if (previousSets.isNotEmpty)
                  Column(
                    children: [
                      LabelContainerDivider(
                          label: "Previous Sets".toUpperCase(),
                          description: "Previously logged sets for ${widget.exerciseLog.exercise.name}",
                          labelStyle:
                              GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                          descriptionStyle: GoogleFonts.ubuntu(
                            color: Colors.white70,
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                          ),
                          dividerColor: sapphireLighter),
                      const SizedBox(height: 12),
                      SetsListview(type: widget.exerciseLog.exercise.type, sets: previousSets),
                      const SizedBox(height: 16),
                    ],
                  ),
                Column(
                  children: [
                    LabelContainerDivider(
                        label: "New Sets".toUpperCase(),
                        description: "Currently logged sets for ${widget.exerciseLog.exercise.name}",
                        labelStyle: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                        descriptionStyle: GoogleFonts.ubuntu(
                          color: Colors.white70,
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                        ),
                        dividerColor: sapphireLighter),
                    const SizedBox(height: 12),
                    SetsListview(type: widget.exerciseLog.exercise.type, sets: updatedExerciseLog.sets)
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onMicPressed() async {
    await HapticFeedback.heavyImpact();

    if (!mounted) return;

    final controller = context.read<STTController>();

    // Start listening again
    await controller.startListening(exerciseType: widget.exerciseLog.exercise.type);
  }
}

class _HeroWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
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
                TextSpan(text: "\n"),
                TextSpan(
                  text: "- Try saying ",
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
                TextSpan(text: "\n"),
                TextSpan(
                  text: "- Or even ",
                  style: GoogleFonts.ubuntu(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: 'Remove last set',
                  style: GoogleFonts.ubuntu(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                TextSpan(text: "\n"),
                TextSpan(
                  text: "- You can say ",
                  style: GoogleFonts.ubuntu(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: 'Update the second set with 25kg',
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
    );
  }
}

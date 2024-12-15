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

import '../../utils/dialog_utils.dart';
import '../../utils/general_utils.dart';
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
      final exerciseLog = widget.exerciseLog;
      final sets = exerciseLog.sets.where((set) => set.isNotEmpty()).toList();
      context.read<STTController>().initialize(initialSets: sets, exerciseType: exerciseLog.exercise.type);
    });
  }

  void _reset() {
    context.read<STTController>().reset();
  }

  @override
  Widget build(BuildContext context) {
    final sttController = context.watch<STTController>();

    if (sttController.state == STTState.analysing) return TRKRLoadingScreen();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (sttController.state) {
        case STTState.notListening:
        case STTState.listening:
        case STTState.analysing:
          // Do Nothing
          break;
        case STTState.noPermission:
          showSnackbar(
              context: context,
              icon: const TRKRCoachWidget(),
              message:
                  "Microphone access is required to continue. Please grant permission to use your microphone and try again");
          break;
        case STTState.error:
          showSnackbar(
              context: context, icon: const TRKRCoachWidget(), message: "Oops! Unable to help with that request.");
          break;
      }
    });

    // Updated ExerciseLog with the recognized sets.
    final updatedExerciseLog = widget.exerciseLog.copyWith(sets: sttController.sets);

    final previousSets = Provider.of<ExerciseAndRoutineController>(context, listen: false)
        .whereSetsForExercise(exercise: widget.exerciseLog.exercise);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Logging ${widget.exerciseLog.exercise.name}".toUpperCase(),
        ),
        leading: IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.squareXmark,
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
        decoration: BoxDecoration(
          gradient: themeGradient(context: context),
        ),
        child: SafeArea(
          bottom: false,
          minimum: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: 60, // Set the width of the container
                  height: 24, // Set the height of the container
                  decoration: BoxDecoration(
                    color: vibrantBlue.withOpacity(0.1), // Background color
                    borderRadius: BorderRadius.circular(3), // Rounded corners
                  ),
                  child: Center(
                    child: Text("Beta".toUpperCase(),
                        style: GoogleFonts.ubuntu(color: vibrantBlue, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                const SizedBox(height: 20),
                _HeroWidget(),
                const SizedBox(height: 20),
                if (previousSets.isNotEmpty)
                  Column(
                    children: [
                      LabelContainerDivider(
                          label: "Previous Sets".toUpperCase(),
                          description: "Previously logged sets for ${widget.exerciseLog.exercise.name}",
                          labelStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w700),
                          descriptionStyle: Theme.of(context).textTheme.bodyMedium!,
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
                        labelStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(color: vibrantGreen, fontWeight: FontWeight.w700),
                        descriptionStyle: Theme.of(context).textTheme.bodyMedium!,
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
    controller.state == STTState.notListening ? controller.startListening() : controller.stopListening();
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
              style: Theme.of(context).textTheme.bodyMedium,
              children: <TextSpan>[
                TextSpan(
                  text: " ",
                ),
                TextSpan(
                  text: "TRKR Coach",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                TextSpan(
                  text: " can help you log sets with your voice only.",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                TextSpan(text: "\n"),
                TextSpan(
                  text: "- Try saying ",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                TextSpan(
                  text: 'Log 25kg for 10 reps',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                TextSpan(text: "\n"),
                TextSpan(
                  text: "- Or even ",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                TextSpan(
                  text: 'Remove last set',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                TextSpan(text: "\n"),
                TextSpan(
                  text: "- You can say ",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                TextSpan(
                  text: 'Update the second set with 25kg',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

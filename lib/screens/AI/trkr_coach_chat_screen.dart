import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/controllers/analytics_controller.dart';
import 'package:tracker_app/controllers/exercise_and_routine_controller.dart';
import 'package:tracker_app/strings/ai_prompts.dart';
import 'package:tracker_app/widgets/ai_widgets/trkr_coach_widget.dart';

import '../../colors.dart';
import '../../dtos/appsync/routine_template_dto.dart';
import '../../dtos/exercise_log_dto.dart';
import '../../dtos/set_dto.dart';
import '../../openAI/open_ai.dart';
import '../../openAI/open_ai_functions.dart';
import '../../shared_prefs.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/routine_utils.dart';
import '../../widgets/backgrounds/trkr_loading_screen.dart';
import '../../widgets/routine/preview/exercise_log_listview.dart';

class TRKRCoachChatScreen extends StatefulWidget {
  static const routeName = '/routine_ai_context_screen';

  const TRKRCoachChatScreen({super.key});

  @override
  State<TRKRCoachChatScreen> createState() => _TRKRCoachChatScreenState();
}

class _TRKRCoachChatScreenState extends State<TRKRCoachChatScreen> {
  bool _loading = false;

  late TextEditingController _textEditingController;

  RoutineTemplateDto? _routineTemplate;

  @override
  Widget build(BuildContext context) {
    if (_loading) return TRKRLoadingScreen(action: _cancelLoadingScreen);

    final routineTemplate = _routineTemplate;

    return Scaffold(
        body: Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AppBar(positiveAction: _navigateBack, canPerformPositiveAction: routineTemplate != null),
            routineTemplate != null
                ? Expanded(
                    child: SingleChildScrollView(
                      child: ExerciseLogListView(
                          exerciseLogs: exerciseLogsToViewModels(exerciseLogs: routineTemplate.exerciseTemplates)),
                    ),
                  )
                : Expanded(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 12,
                        ),
                        _HeroWidget(),
                        const Spacer()
                      ],
                    ),
                  ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _textEditingController,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: Colors.white10)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: Colors.white30)),
                        filled: true,
                        fillColor: Colors.white10,
                        hintText: "Describe your workout",
                        hintStyle:
                            GoogleFonts.ubuntu(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w400)),
                    maxLines: null,
                    cursorColor: Colors.white,
                    showCursor: true,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    style: GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.white, fontSize: 16),
                  ),
                ),
                IconButton(
                  onPressed: _runMessage,
                  icon: const FaIcon(FontAwesomeIcons.paperPlane),
                  color: Colors.white,
                )
              ],
            ),
          ],
        ),
      ),
    ));
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

  void _showSnackbar(String message, {Widget? icon}) {
    showSnackbar(context: context, icon: icon ?? const Icon(Icons.info_outline), message: message);
  }

  void _cancelLoadingScreen() {
    setState(() {
      _loading = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  void _runMessage() async {
    AnalyticsController.aiInteractions(aiModule: "TRKR_coach", eventAction: "user_prompt");
    final userPrompt = _textEditingController.text;

    if (userPrompt.isNotEmpty) {
      _dismissKeyboard();
      _showLoadingScreen();
      _clearTextEditing();

      final routineTemplate = await _runFunctionMessage(userInstruction: userPrompt);

      setState(() {
        _routineTemplate = routineTemplate;
      });

      _hideLoadingScreen();
    }
  }

  Future<RoutineTemplateDto?> _runFunctionMessage({required String userInstruction}) async {
    RoutineTemplateDto? templateDto;

    final StringBuffer buffer = StringBuffer();

    buffer.writeln(personalTrainerInstructionForWorkouts);
    buffer.writeln("For each muscle group, suggest two exercises.");
    buffer.writeln("Ensure one exercise targets the muscle group primarily or secondarily.");
    buffer.writeln("Both exercises must engage the muscle group from both the lengthened and shortened positions.");

    final completeSystemInstructions = buffer.toString();

    final tool = await runMessageWithTools(
        systemInstruction: personalTrainerInstructionForWorkouts,
        userInstruction: userInstruction,
        callback: (message) {
          _showSnackbar("Oops, I can only assist you with workouts.", icon: TRKRCoachWidget());
        });
    if (tool != null) {
      final toolId = tool['id'];
      final toolName = tool['name']; // A function
      if (toolName == "list_exercises") {
        if (mounted) {
          final exercises = Provider.of<ExerciseAndRoutineController>(context, listen: false).exercises;
          final functionCallPayload = await createFunctionCallPayload(
              toolId: toolId,
              systemInstruction: completeSystemInstructions,
              user: userInstruction,
              responseFormat: newRoutineTemplateResponseFormat,
              exercises: exercises);
          final jsonString = await runMessageWithFunctionCallResult(payload: functionCallPayload);
          if (jsonString != null) {
            final json = jsonDecode(jsonString);
            final exerciseIds = json["exercises"] as List<dynamic>;
            final workoutName = json["workout_name"] ?? "A workout";
            final workoutCaption = json["workout_caption"] ?? "A workout created by TRKR Coach";
            final exerciseTemplates = exerciseIds.map((exerciseId) {
              final exerciseInLibrary = exercises.firstWhere((exercise) => exercise.id == exerciseId);
              final exerciseTemplate = ExerciseLogDto(exerciseInLibrary.id, "", "", exerciseInLibrary,
                  exerciseInLibrary.description ?? "", [const SetDto(0, 0, false)], DateTime.now(), []);
              return exerciseTemplate;
            }).toList();
            templateDto = RoutineTemplateDto(
                id: "",
                name: workoutName,
                exerciseTemplates: exerciseTemplates,
                notes: workoutCaption,
                owner: SharedPrefs().userId,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now());
          }
        }
      } else {
        _showSnackbar("Oops, I can only assist you with workouts.", icon: TRKRCoachWidget());
      }
    }
    return templateDto;
  }

  void _clearTextEditing() {
    setState(() {
      _textEditingController.clear();
    });
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void _navigateBack() {
    context.pop(_routineTemplate);
  }
}

class _AppBar extends StatelessWidget {
  final VoidCallback positiveAction;
  final bool canPerformPositiveAction;

  const _AppBar({required this.positiveAction, this.canPerformPositiveAction = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.squareXmark, color: Colors.white, size: 28),
          onPressed: Navigator.of(context).pop,
        ),
        Expanded(
          child: Text("TRKR Coach".toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
        ),
        canPerformPositiveAction
            ? IconButton(
                icon: const FaIcon(FontAwesomeIcons.solidSquareCheck, color: Colors.white, size: 28),
                onPressed: positiveAction,
              )
            : const IconButton(
                icon: SizedBox.shrink(),
                onPressed: null,
              )
      ],
    );
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

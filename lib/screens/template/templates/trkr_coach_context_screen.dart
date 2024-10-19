import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/strings/ai_prompts.dart';
import 'package:tracker_app/widgets/ai_widgets/trkr_coach_widget.dart';

import '../../../controllers/exercise_controller.dart';
import '../../../dtos/exercise_log_dto.dart';
import '../../../dtos/routine_template_dto.dart';
import '../../../dtos/set_dto.dart';
import '../../../enums/routine_preview_type_enum.dart';
import '../../../openAI/open_ai.dart';
import '../../../openAI/open_ai_functions.dart';
import '../../../shared_prefs.dart';
import '../../../utils/routine_utils.dart';
import '../../../widgets/backgrounds/trkr_loading_screen.dart';
import '../../../widgets/routine/preview/exercise_log_listview.dart';

class TRKRCoachContextScreen extends StatefulWidget {
  static const routeName = '/routine_ai_context_screen';

  const TRKRCoachContextScreen({super.key});

  @override
  State<TRKRCoachContextScreen> createState() => _TRKRCoachContextScreenState();
}

class _TRKRCoachContextScreenState extends State<TRKRCoachContextScreen> {
  bool _loading = false;

  late TextEditingController _textEditingController;

  RoutineTemplateDto? _routineTemplate;

  void _toggleLoadingState() {
    setState(() {
      _loading = !_loading;
    });
  }

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
        gradient: SweepGradient(
          colors: [Colors.green.shade900, Colors.blue.shade900],
          stops: const [0, 1],
          center: Alignment.topRight,
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
                        exerciseLogs: exerciseLogsToViewModels(exerciseLogs: routineTemplate.exerciseTemplates),
                        previewType: RoutinePreviewType.ai,
                      ),
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
    final userPrompt = _textEditingController.text;

    if (userPrompt.isNotEmpty) {
      _dismissKeyboard();
      _toggleLoadingState();
      _clearTextEditing();

      final routineTemplate =
          await _runFunctionMessage(system: defaultSystemInstructionWorkouts, user: userPrompt, context: context);
      setState(() {
        _routineTemplate = routineTemplate;
      });

      _toggleLoadingState();
    }
  }

  Future<RoutineTemplateDto?> _runFunctionMessage(
      {required String system, required String user, required BuildContext context}) async {
    RoutineTemplateDto? templateDto;

    final response = await runMessageWithFunctionCall(system: system, user: user);
    if (response != null) {
      final choices = response;
      if (choices.isNotEmpty) {
        final choice = choices[0];
        final toolCalls = choice['message']['tool_calls'] as List<dynamic>;
        if (toolCalls.isNotEmpty) {
          final tool = toolCalls[0];
          final function = tool['function']['name'];
          if (function == "list_exercises") {
            if (context.mounted) {
              final exercises = Provider.of<ExerciseController>(context, listen: false).exercises;
              final listOfExerciseJsons = exercises
                  .map((exercise) => jsonEncode({
                        "id": exercise.id,
                        "name": exercise.name,
                        "primary_muscle_group": exercise.primaryMuscleGroup.name,
                        "secondary_muscle_groups":
                            exercise.secondaryMuscleGroups.map((muscleGroup) => muscleGroup.name).toList()
                      }))
                  .toList();

              final functionCallMessage = {
                "role": "assistant",
                "tool_calls": [
                  {
                    "id": tool["id"],
                    "type": "function",
                    "function": {"arguments": "{}", "name": "list_exercises"}
                  }
                ]
              };

              final functionCallResultMessage = {
                "role": "tool",
                "content": jsonEncode({
                  "exercises": listOfExerciseJsons,
                }),
                "tool_call_id": tool["id"]
              };

              final payload = jsonEncode({
                "model": "gpt-4o-mini",
                "messages": [
                  {"role": "system", "content": defaultSystemInstructionWorkouts},
                  {"role": "user", "content": user},
                  functionCallMessage,
                  functionCallResultMessage
                ],
                "response_format": newRoutineTemplateResponseFormat
              });

              final jsonString = await runMessageWithFunctionCallResult(payload: payload);
              if (jsonString != null) {
                final json = jsonDecode(jsonString);
                final exerciseIds = json["exercises"] as List<dynamic>;
                final workoutName = json["workout_name"] ?? "A workout";
                final workoutCaption = json["workout_caption"] ?? "A workout created by TRKR Coach";
                final exerciseTemplates = exerciseIds.map((exerciseId) {
                  final exerciseInLibrary = exercises.firstWhere((exercise) => exercise.id == exerciseId);
                  final exerciseTemplate = ExerciseLogDto(exerciseInLibrary.id, "", "", exerciseInLibrary, "",
                      [const SetDto(0, 0, false)], DateTime.now(), []);
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
          }
        }
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
          icon: const FaIcon(FontAwesomeIcons.xmark, color: Colors.white, size: 28),
          onPressed: context.pop,
        ),
        Expanded(
          child: Text("TRKR Coach".toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
        ),
        canPerformPositiveAction
            ? IconButton(
                icon: const FaIcon(FontAwesomeIcons.check, color: Colors.white, size: 28),
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
                text: "Hey there! TRKR Coach",
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
                      text: "Start with the suggestions below.",
                      style: GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white10.withOpacity(0.1), // Background color of the container
                borderRadius: BorderRadius.circular(5), // Rounded corners
              ),
              child: Text("Create a fullbody workout",
                  style: GoogleFonts.ubuntu(
                      color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white10.withOpacity(0.1), // Background color of the container
                borderRadius: BorderRadius.circular(5), // Rounded corners
              ),
              child: Text("Help me create a back and biceps workout",
                  style: GoogleFonts.ubuntu(
                      color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white10.withOpacity(0.1), // Background color of the container
                borderRadius: BorderRadius.circular(5), // Rounded corners
              ),
              child: Text("I need a machine-only workout",
                  style: GoogleFonts.ubuntu(
                      color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ]),
        )
      ]),
    );
  }
}

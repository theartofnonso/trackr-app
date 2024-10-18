import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/dtos/routine_template_dto.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/strings/ai_prompts.dart';
import 'package:tracker_app/widgets/trkr_widgets/trkr_coach_widget.dart';

import '../../../controllers/exercise_controller.dart';
import '../../../enums/routine_preview_type_enum.dart';
import '../../../open_ai.dart';
import '../../../open_ai_functions.dart';
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

  List<ExerciseLogDto> _exerciseTemplates = [];

  void _toggleLoadingState() {
    setState(() {
      _loading = !_loading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: SweepGradient(
          colors: [Colors.green.shade900, Colors.blue.shade900],
          stops: const [0, 1],
          center: Alignment.topRight,
        ),
      ),
      child: Stack(children: [
        SafeArea(
          minimum: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _AppBar(),
              _exerciseTemplates.isNotEmpty
                  ? Expanded(
                      child: SingleChildScrollView(
                        child: ExerciseLogListView(
                          exerciseLogs: exerciseLogsToViewModels(exerciseLogs: _exerciseTemplates),
                          previewType: RoutinePreviewType.template,
                        ),
                      ),
                    )
                  : const Spacer(),
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
                          hintText: "Start typing",
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
        if (_loading) const TRKRLoadingScreen()
      ]),
    ));
  }

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  void _runMessage() async {
    _dismissKeyboard();
    _toggleLoadingState();

    final response =
        await runMessageWithFunctionCall(system: defaultSystemInstruction, user: _textEditingController.text);
    if (response != null) {
      final choices = response;
      if (choices.isNotEmpty) {
        final choice = choices[0];
        final toolCalls = choice['message']['tool_calls'] as List<dynamic>;
        if (toolCalls.isNotEmpty) {
          final tool = toolCalls[0];
          final function = tool['function']['name'];
          if (function == "list_exercises") {
            if (mounted) {
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
                  {"role": "system", "content": defaultSystemInstruction},
                  {"role": "user", "content": _textEditingController.text},
                  functionCallMessage,
                  functionCallResultMessage
                ],
                "response_format": exercisesResponseFormat
              });

              final jsonString = await runMessageWithFunctionCallResult(payload: payload);
              if (jsonString != null) {
                final json = jsonDecode(jsonString);
                final exerciseIds = json["exercises"] as List<dynamic>;
                final exerciseTemplates = exerciseIds.map((exerciseId) {
                  final exerciseInLibrary = exercises.firstWhere((exercise) => exercise.id == exerciseId);
                  final exerciseTemplate = ExerciseLogDto(exerciseInLibrary.id, "", "", exerciseInLibrary, "",
                      [const SetDto(0, 0, false)], DateTime.now(), []);
                  return exerciseTemplate;
                }).toList();
                setState(() {
                  _exerciseTemplates = exerciseTemplates;
                });
              }
              _toggleLoadingState();
            }
          }
        }
      }
    }
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar();

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
        IconButton(
          icon: const SizedBox.shrink(),
          onPressed: () {},
        )
      ],
    );
  }
}

class _HeroWidget extends StatelessWidget {
  final RoutineTemplateDto template;

  const _HeroWidget({
    required this.template,
  });

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
                text: "Hey there! TRKR Coach can help you optimise",
                style: GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white, height: 1.5),
                children: <TextSpan>[
                  const TextSpan(text: " "),
                  TextSpan(
                      text: template.name,
                      style: GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const TextSpan(text: ". "),
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
              child: Text("Optimise for a specific goal ",
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
              child: Text("Reduce time spent when training",
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
              child: Text("Focus on particular muscle group",
                  style: GoogleFonts.ubuntu(
                      color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ]),
        )
      ]),
    );
  }
}

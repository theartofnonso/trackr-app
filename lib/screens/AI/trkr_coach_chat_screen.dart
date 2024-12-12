import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/controllers/analytics_controller.dart';
import 'package:tracker_app/controllers/exercise_and_routine_controller.dart';
import 'package:tracker_app/dtos/appsync/exercise_dto.dart';
import 'package:tracker_app/dtos/open_ai_response_schema_dtos/new_routine_dto.dart';
import 'package:tracker_app/dtos/set_dtos/set_dto.dart';
import 'package:tracker_app/strings/ai_prompts.dart';
import 'package:tracker_app/widgets/ai_widgets/trkr_coach_widget.dart';

import '../../colors.dart';
import '../../dtos/appsync/routine_template_dto.dart';
import '../../dtos/exercise_log_dto.dart';
import '../../dtos/open_ai_response_schema_dtos/tool_dto.dart';
import '../../enums/posthog_analytics_event.dart';
import '../../openAI/open_ai.dart';
import '../../openAI/open_ai_response_format.dart';
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
    if (_loading) return TRKRLoadingScreen(action: _hideLoadingScreen);

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
        bottom: false,
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
            SafeArea(
              child: Row(
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

      _runFunctionMessage(userInstruction: userPrompt);
    }
  }

  Future<void> _runFunctionMessage({required String userInstruction}) async {
    final StringBuffer buffer = StringBuffer();

    buffer.writeln(userInstruction);

    buffer.writeln();

    buffer.writeln("Note: Suggest a balanced combination of exercises engaging all muscle groups.");

    final completeSystemInstructions = buffer.toString();

    _showLoadingScreen();

    try {
      final json = await runMessageWithTools(
        systemInstruction: personalTrainerInstructionForWorkouts,
        userInstruction: userInstruction,
      );

      if (json == null) {
        _handleError();
        return;
      }

      final tool = ToolDto.fromJson(json);

      if (tool.name == "list_exercises") {

        if (!mounted) return;

        final exercises = Provider.of<ExerciseAndRoutineController>(
          context,
          listen: false,
        ).exercises;

        await _recommendExercises(
            tool: tool,
            systemInstruction: completeSystemInstructions,
            userInstruction: userInstruction,
            exercises: exercises);
      }
    } catch (e) {

      print(e);
      _handleError();
    }
  }

  void _handleError() {
    _hideLoadingScreen();
    _showSnackbar(
      "Oops, I can only assist you with workouts.",
      icon: TRKRCoachWidget(),
    );
  }

  Future<void> _recommendExercises(
      {required ToolDto tool,
      required String systemInstruction,
      required String userInstruction,
      required List<ExerciseDto> exercises}) async {
    final listOfExerciseJsons = {
      "exercises": exercises
          .map((exercise) => {
                "id": exercise.id,
                "name": exercise.name,
                "primary_muscle_group": exercise.primaryMuscleGroup.name,
                "secondary_muscle_groups":
                    exercise.secondaryMuscleGroups.map((muscleGroup) => muscleGroup.name).toList()
              })
          .toList(),
    };

    final functionCallPayload = createFunctionCallPayload(
        tool: tool,
        systemInstruction: systemInstruction,
        user: userInstruction,
        responseFormat: newRoutineResponseFormat,
        functionName: "list_exercises",
        extra: jsonEncode(listOfExerciseJsons));

    try {
      final functionCallResult = await runMessageWithFunctionCallPayload(payload: functionCallPayload);

      if (functionCallResult == null) {
        _handleError();
        return;
      }

      // Deserialize the JSON string
      Map<String, Object> json = jsonDecode(functionCallResult);

      if(kReleaseMode) {
        Posthog().capture(eventName: PostHogAnalyticsEvent.createRoutineTemplateAI.displayName, properties: json);
      }

      NewRoutineDto newRoutineDto = NewRoutineDto.fromJson(json);

      final exerciseTemplates = _createExerciseTemplates(newRoutineDto.exercises, exercises);

      setState(() {
        _routineTemplate = RoutineTemplateDto(
          id: "",
          name: newRoutineDto.workoutName,
          exerciseTemplates: exerciseTemplates,
          notes: newRoutineDto.workoutCaption,
          owner: SharedPrefs().userId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      });
      _hideLoadingScreen();
    } catch (e) {
      _handleError();
    }
  }

  List<ExerciseLogDto> _createExerciseTemplates(List<String> exerciseIds, List<ExerciseDto> exercises) {
    return exerciseIds
        .map((exerciseId) {
          final exerciseInLibrary = exercises.firstWhereOrNull((exercise) => exercise.id == exerciseId);
          if (exerciseInLibrary == null) return null;
          return ExerciseLogDto(
              id: exerciseInLibrary.id,
              routineLogId: "",
              superSetId: "",
              exercise: exerciseInLibrary,
              notes: exerciseInLibrary.description ?? "",
              sets: [SetDto.newType(type: exerciseInLibrary.type)],
              createdAt: DateTime.now());
        })
        .whereType<ExerciseLogDto>()
        .toList();
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

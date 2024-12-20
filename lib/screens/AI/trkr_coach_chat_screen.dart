import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/controllers/analytics_controller.dart';
import 'package:tracker_app/controllers/exercise_and_routine_controller.dart';
import 'package:tracker_app/dtos/appsync/exercise_dto.dart';
import 'package:tracker_app/dtos/open_ai_response_schema_dtos/new_routine_dto.dart';
import 'package:tracker_app/dtos/set_dtos/set_dto.dart';
import 'package:tracker_app/strings/ai_prompts.dart';
import 'package:tracker_app/widgets/ai_widgets/trkr_coach_widget.dart';

import '../../dtos/appsync/routine_template_dto.dart';
import '../../dtos/exercise_log_dto.dart';
import '../../dtos/open_ai_response_schema_dtos/tool_dto.dart';
import '../../openAI/open_ai.dart';
import '../../openAI/open_ai_response_format.dart';
import '../../shared_prefs.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/general_utils.dart';
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

    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    if (_loading) return TRKRLoadingScreen(action: _hideLoadingScreen);

    final routineTemplate = _routineTemplate;

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.squareXmark, size: 28),
            onPressed: Navigator.of(context).pop,
          ),
          title: Text("TRKR Coach".toUpperCase()),
          actions: [
            routineTemplate != null
                ? IconButton(
                    icon: const FaIcon(FontAwesomeIcons.solidSquareCheck, size: 28),
                    onPressed: _navigateBack,
                  )
                : const IconButton(
                    icon: SizedBox.shrink(),
                    onPressed: null,
                  )
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: themeGradient(context: context),
          ),
          child: SafeArea(
            bottom: false,
            minimum: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  minimum: EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textEditingController,
                          decoration: InputDecoration(hintText: "Describe your workout"),
                          cursorColor: isDarkMode ? Colors.white : Colors.black,
                          maxLines: null,
                          showCursor: true,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ),
                      IconButton(
                        onPressed: _runMessage,
                        icon: const FaIcon(FontAwesomeIcons.paperPlane),
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
      Map<String, dynamic> json = jsonDecode(functionCallResult);

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
                style: Theme.of(context).textTheme.bodyLarge,
                children: <TextSpan>[
                  TextSpan(text: " ", style: Theme.of(context).textTheme.bodyLarge),
                  TextSpan(text: "TRKR Coach", style: Theme.of(context).textTheme.bodyLarge),
                  TextSpan(text: " ", style: Theme.of(context).textTheme.bodyLarge),
                  TextSpan(text: "can help you create awesome workouts", style: Theme.of(context).textTheme.bodyLarge),
                  TextSpan(text: ".", style: Theme.of(context).textTheme.bodyLarge),
                  TextSpan(text: " ", style: Theme.of(context).textTheme.bodyLarge),
                  TextSpan(text: "Try saying", style: Theme.of(context).textTheme.bodyLarge),
                  TextSpan(text: " ", style: Theme.of(context).textTheme.bodyLarge),
                  TextSpan(
                      text: 'I want to train "mention muscle group(s)"', style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            )
          ]),
        )
      ]),
    );
  }
}

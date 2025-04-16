import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
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
                        child: SingleChildScrollView(
                          child: StaggeredGrid.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            children: [
                              StaggeredGridTile.count(
                                crossAxisCellCount: 1,
                                mainAxisCellCount: 1,
                                child: _Tile(title: "Show me a chest, leg exercises with or without equipment"),
                              ),
                              StaggeredGridTile.count(
                                crossAxisCellCount: 1,
                                mainAxisCellCount: 1,
                                child: _Tile(title: "What exercises should I do for chest, legs, or full body?"),
                              ),
                              StaggeredGridTile.count(
                                crossAxisCellCount: 1,
                                mainAxisCellCount: 1,
                                child: _Tile(title: "I need a quick fullbody workout — what can I do?"),
                              ),
                              StaggeredGridTile.count(
                                crossAxisCellCount: 1,
                                mainAxisCellCount: 1,
                                child: _Tile(title: "I need a Push, Pull or Legs workout"),
                              ),
                            ],
                          ),
                        ),
                      ),
                const SizedBox(height: 10),
                SafeArea(
                  minimum: EdgeInsets.symmetric(horizontal: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                        icon: Container(
                          width: 50,
                          height: 50,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDarkMode ? vibrantGreen.withValues(alpha: 0.1) : vibrantGreen.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: FaIcon(
                              FontAwesomeIcons.rocket,
                              size: 20,
                            ),
                          ),
                        ),
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
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
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

    buffer.writeln(createRoutinePrompt);

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

class _Tile extends StatelessWidget {
  final String title;

  const _Tile({required this.title});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(5)),
      child: Text(title, style: GoogleFonts.ubuntu(fontSize: 18, height: 1.5, fontWeight: FontWeight.w400)),
    );
  }
}

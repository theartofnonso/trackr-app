import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';

import '../../controllers/exercise_and_routine_controller.dart';
import '../../dtos/appsync/exercise_dto.dart';
import '../../dtos/appsync/routine_log_dto.dart';
import '../../dtos/appsync/routine_plan_dto.dart';
import '../../dtos/appsync/routine_template_dto.dart';
import '../../dtos/exercise_log_dto.dart';
import '../../dtos/open_ai_response_schema_dtos/new_routine_plan_dto.dart';
import '../../dtos/open_ai_response_schema_dtos/tool_dto.dart';
import '../../dtos/set_dtos/set_dto.dart';
import '../../openAI/open_ai.dart';
import '../../openAI/open_ai_response_format.dart';
import '../../shared_prefs.dart';
import '../../strings/ai_prompts.dart';
import '../../utils/date_utils.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/general_utils.dart';
import '../../utils/navigation_utils.dart';
import '../../utils/string_utils.dart';
import '../../widgets/ai_widgets/trkr_coach_widget.dart';
import '../../widgets/backgrounds/trkr_loading_screen.dart';
import '../../widgets/empty_states/no_list_empty_state.dart';
import '../../widgets/information_containers/information_container_with_background_image.dart';
import '../../widgets/routine/preview/routine_plan_grid_item.dart';

class RoutinePlansScreen extends StatefulWidget {
  static const routeName = '/routine_plans_screen';

  const RoutinePlansScreen({super.key});

  @override
  State<RoutinePlansScreen> createState() => _RoutinePlansScreenState();
}

class _RoutinePlansScreenState extends State<RoutinePlansScreen> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    if (_loading) return TRKRLoadingScreen(action: _hideLoadingScreen);

    return Consumer<ExerciseAndRoutineController>(builder: (_, provider, __) {
      final plans = List<RoutinePlanDto>.from(provider.plans);

      final children = plans.map((plan) => RoutinePlanGridItemWidget(plan: plan)).toList();

      return Scaffold(
          floatingActionButton: FloatingActionButton(
            heroTag: "fab_routines_screen",
            onPressed: () => navigateToRoutineTemplateEditor(context: context),
            child: const FaIcon(FontAwesomeIcons.plus, size: 28),
          ),
          body: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: themeGradient(context: context),
            ),
            child: SafeArea(
              minimum: const EdgeInsets.only(top: 10, right: 10, left: 10),
              bottom: false,
              child: Column(spacing: 16, crossAxisAlignment: CrossAxisAlignment.start, children: [
                GestureDetector(
                  onTap: _runMessage,
                  child: BackgroundInformationContainer(
                    image: 'images/lace.jpg',
                    containerColor: Colors.green.shade800,
                    content: "Plans are workouts curated to guide you toward a fitness goal.",
                    textStyle: GoogleFonts.ubuntu(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    ctaContent: 'Get a personalised plan',
                  ),
                ),
                plans.isNotEmpty
                    ? Expanded(
                        child: GridView.count(
                            crossAxisCount: 2,
                            childAspectRatio: 1,
                            mainAxisSpacing: 10.0,
                            crossAxisSpacing: 10.0,
                            children: children),
                      )
                    : Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: const NoListEmptyState(
                              message:
                                  "It might feel quiet now, but tap the + button to create a workout or ask TRKR coach for help."),
                        ),
                      ),
              ]),
            ),
          ));
    });
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

  void _runMessage() async {
    _runFunctionMessage();
  }

  Future<void> _runFunctionMessage() async {
    final exerciseAndRoutineController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    final dateRange = theLastYearDateTimeRange();

    final logs = exerciseAndRoutineController.whereLogsIsWithinRange(range: dateRange).toList();

    final weeksInLastYear = generateWeeksInRange(range: dateRange).reversed.take(13).toList().reversed;

    List<String> months = [];
    List<int> days = [];
    List<RoutineLogDto> logsByWeek = [];
    for (final week in weeksInLastYear) {
      final startOfWeek = week.start;
      final endOfWeek = week.end;
      final logsForTheWeek = logs.where((log) => log.createdAt.isBetweenInclusive(from: startOfWeek, to: endOfWeek));
      final routineLogsByDay = groupBy(logsForTheWeek, (log) => log.createdAt.withoutTime().day);
      days.add(routineLogsByDay.length);
      months.add(startOfWeek.abbreviatedMonth());
      logsByWeek.addAll(logsForTheWeek);
    }

    final previousDays = days.sublist(0, days.length - 1);
    final averageOfPrevious = (previousDays.reduce((a, b) => a + b) / previousDays.length).round();

    final exercises = logs
        .expand((log) => log.exerciseLogs)
        .map((exerciseLog) => "id: ${exerciseLog.exercise.id} name: ${exerciseLog.exercise.name}")
        .toList();

    final userInstruction =
        "I need a workout plan. I typically train $averageOfPrevious ${pluralize(word: 'time', count: averageOfPrevious)} per week. The exercises I enjoy most include ${joinWithAnd(items: exercises)}";

    _showLoadingScreen();

    try {
      final json = await runMessageWithTools(
        systemInstruction: createRoutinePlanPrompt,
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
            systemInstruction: createRoutinePlanPrompt,
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
        responseFormat: newRoutinePlanResponseFormat,
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

      NewRoutinePlanDto newRoutinePlanDto = NewRoutinePlanDto.fromJson(json);

      final routineTemplates = newRoutinePlanDto.workouts.map((newRoutineDto) {
        final exerciseTemplates = _createExerciseTemplates(newRoutineDto.exercises, exercises);
        return RoutineTemplateDto(
          id: "",
          name: newRoutineDto.workoutName,
          exerciseTemplates: exerciseTemplates,
          notes: newRoutineDto.workoutCaption,
          owner: SharedPrefs().userId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }).toList();

      final newPlan = RoutinePlanDto(
        id: "",
        name: newRoutinePlanDto.planName,
        notes: newRoutinePlanDto.planDescription,
        owner: SharedPrefs().userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (mounted) {
        final createdPlan = await _savePlan(context: context, plan: newPlan);
        if (mounted) {
          if (createdPlan != null) {
            for (final template in routineTemplates) {
              final templateWithPlanId = template.copyWith(planId: createdPlan.id);
              _saveTemplate(context: context, template: templateWithPlanId);
            }
          }
        }
      }

      _hideLoadingScreen();
    } catch (e) {
      _handleError();
    }
  }

  Future<RoutinePlanDto?> _savePlan({required BuildContext context, required RoutinePlanDto plan}) async {
    final planController = Provider.of<ExerciseAndRoutineController>(context, listen: false);
    final createdPlan = await planController.savePlan(planDto: plan);
    return createdPlan;
  }

  void _saveTemplate({required BuildContext context, required RoutineTemplateDto template}) async {
    final templateController = Provider.of<ExerciseAndRoutineController>(context, listen: false);
    await templateController.saveTemplate(templateDto: template);
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
}

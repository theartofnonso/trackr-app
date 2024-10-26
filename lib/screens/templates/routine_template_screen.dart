import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/controllers/exercise_controller.dart';
import 'package:tracker_app/extensions/amplify_models/routine_template_extension.dart';
import 'package:tracker_app/screens/AI/trkr_coach_exercise_recommendation_screen.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/widgets/buttons/opacity_button_widget.dart';

import '../../colors.dart';
import '../../controllers/routine_template_controller.dart';
import '../../dtos/exercise_log_dto.dart';
import '../../dtos/routine_template_dto.dart';
import '../../dtos/set_dto.dart';
import '../../dtos/viewmodels/routine_log_arguments.dart';
import '../../dtos/viewmodels/routine_template_arguments.dart';
import '../../enums/muscle_group_enums.dart';
import '../../enums/routine_editor_type_enums.dart';
import '../../enums/routine_preview_type_enum.dart';
import '../../models/RoutineTemplate.dart';
import '../../openAI/open_ai.dart';
import '../../openAI/open_ai_functions.dart';
import '../../strings/ai_prompts.dart';
import '../../urls.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/exercise_logs_utils.dart';
import '../../utils/https_utils.dart';
import '../../utils/navigation_utils.dart';
import '../../utils/routine_utils.dart';
import '../../utils/string_utils.dart';
import '../../widgets/ai_widgets/trkr_information_container.dart';
import '../../widgets/backgrounds/trkr_loading_screen.dart';
import '../../widgets/chart/muscle_group_family_chart.dart';
import '../../widgets/routine/preview/exercise_log_listview.dart';
import '../not_found.dart';
import 'routine_day_planner.dart';

class RoutineTemplateScreen extends StatefulWidget {
  static const routeName = '/routine_template_screen';

  final String id;

  const RoutineTemplateScreen({super.key, required this.id});

  @override
  State<RoutineTemplateScreen> createState() => _RoutineTemplateScreenState();
}

class _RoutineTemplateScreenState extends State<RoutineTemplateScreen> {
  RoutineTemplateDto? _template;

  bool _loading = false;

  bool _minimized = true;

  void _deleteRoutine({required RoutineTemplateDto template}) async {
    try {
      await Provider.of<RoutineTemplateController>(context, listen: false).removeTemplate(template: template);
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        showSnackbar(context: context, icon: const Icon(Icons.info_outline), message: "Unable to remove workout");
      }
    } finally {
      _toggleLoadingState();
    }
  }

  void _toggleLoadingState() {
    setState(() {
      _loading = !_loading;
    });
  }

  void _navigateToRoutineTemplateEditor() async {
    final template = _template;
    if (template != null) {
      final arguments = RoutineTemplateArguments(template: template);
      final updatedTemplate = await navigateToRoutineTemplateEditor(context: context, arguments: arguments);
      if (updatedTemplate != null) {
        setState(() {
          _template = updatedTemplate;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return TRKRLoadingScreen(action: _hideLoadingScreen);

    final template = _template;

    if (template == null) return const NotFound();

    final numberOfSets = template.exerciseTemplates.expand((exerciseTemplate) => exerciseTemplate.sets);
    final setsSummary = "${numberOfSets.length} ${pluralize(word: "Set", count: numberOfSets.length)}";

    final exerciseController = Provider.of<ExerciseController>(context, listen: true);

    final exercisesFromLibrary = template.exerciseTemplates.map((exerciseTemplate) {
      final foundExercise = exerciseController.exercises
          .firstWhereOrNull((exerciseInLibrary) => exerciseInLibrary.id == exerciseTemplate.id);
      return foundExercise != null ? exerciseTemplate.copyWith(exercise: foundExercise) : exerciseTemplate;
    }).toList();

    final muscleGroupFamilyFrequencies = muscleGroupFamilyFrequency(exerciseLogs: exercisesFromLibrary);

    final menuActions = [
      MenuItemButton(onPressed: _navigateToRoutineTemplateEditor, child: Text("Edit", style: GoogleFonts.ubuntu())),
      MenuItemButton(
        onPressed: () {
          displayBottomSheet(
              context: context,
              child: RoutineDayPlanner(template: template));
        },
        child: Text("Schedule", style: GoogleFonts.ubuntu(color: Colors.white)),
      ),
      MenuItemButton(onPressed: _showBottomSheet, child: Text("Share", style: GoogleFonts.ubuntu())),
      MenuItemButton(
        onPressed: () {
          showBottomSheetWithMultiActions(
              context: context,
              title: "Delete workout?",
              description: "Are you sure you want to delete this workout?",
              leftAction: Navigator.of(context).pop,
              rightAction: () {
                context.pop();
                _toggleLoadingState();
                _deleteRoutine(template: template);
              },
              leftActionLabel: 'Cancel',
              rightActionLabel: 'Delete',
              isRightActionDestructive: true);
        },
        child: Text("Delete", style: GoogleFonts.ubuntu(color: Colors.red)),
      )
    ];

    return Scaffold(
        floatingActionButton: FloatingActionButton(
            heroTag: UniqueKey,
            onPressed: template.owner == SharedPrefs().userId ? _launchRoutineLogEditor : _createTemplate,
            backgroundColor: sapphireDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: template.owner == SharedPrefs().userId
                ? const FaIcon(FontAwesomeIcons.play, color: Colors.white, size: 24)
                : const FaIcon(FontAwesomeIcons.download)),
        backgroundColor: sapphireDark,
        appBar: AppBar(
          backgroundColor: sapphireDark80,
          leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
            onPressed: context.pop,
          ),
          centerTitle: true,
          title: Text(template.name,
              style: GoogleFonts.ubuntu(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)),
          actions: [
            template.owner == SharedPrefs().userId
                ? MenuAnchor(
                    style: MenuStyle(
                      backgroundColor: WidgetStateProperty.all(sapphireDark80),
                      surfaceTintColor: WidgetStateProperty.all(sapphireDark),
                    ),
                    builder: (BuildContext context, MenuController controller, Widget? child) {
                      return IconButton(
                        onPressed: () {
                          if (controller.isOpen) {
                            controller.close();
                          } else {
                            controller.open();
                          }
                        },
                        icon: const Icon(
                          Icons.more_vert_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        tooltip: 'Show menu',
                      );
                    },
                    menuChildren: menuActions,
                  )
                : const SizedBox.shrink()
          ],
        ),
        body: Container(
          width: double.infinity,
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
            minimum: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.solidClock,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 6),
                      Text(scheduledDaysSummary(template: template),
                          style: GoogleFonts.ubuntu(
                              color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w500, fontSize: 12)),
                    ],
                  ),
                  if (template.notes.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                      child: Text('"${template.notes}"',
                          textAlign: TextAlign.start,
                          style: GoogleFonts.ubuntu(
                              color: Colors.white70,
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600)),
                    ),

                  /// Keep this spacing for when notes isn't available
                  if (template.notes.isEmpty)
                    const SizedBox(
                      height: 10,
                    ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5), // Use BorderRadius.circular for a rounded container
                      color: sapphireDark.withOpacity(0.4), // Set the background color
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Table(
                      border: const TableBorder.symmetric(inside: BorderSide(color: sapphireLighter, width: 2)),
                      columnWidths: const <int, TableColumnWidth>{
                        0: FlexColumnWidth(),
                        1: FlexColumnWidth(),
                      },
                      children: [
                        TableRow(children: [
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Center(
                              child: Text(
                                  "${template.exerciseTemplates.length} ${pluralize(word: "Exercise", count: template.exerciseTemplates.length)}",
                                  style: GoogleFonts.ubuntu(
                                      color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
                            ),
                          ),
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Center(
                              child: Text(setsSummary,
                                  style: GoogleFonts.ubuntu(
                                      color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _onMinimiseMuscleGroupSplit,
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text("Muscle Groups Split".toUpperCase(),
                                style: GoogleFonts.ubuntu(
                                    color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                            const Spacer(),
                            if (muscleGroupFamilyFrequencies.length > 3)
                              FaIcon(_minimized ? FontAwesomeIcons.angleDown : FontAwesomeIcons.angleUp,
                                  color: Colors.white70, size: 16),
                          ]),
                          const SizedBox(height: 10),
                          Text("Here's a breakdown of the muscle groups in your ${template.name} workout plan.",
                              style:
                                  GoogleFonts.ubuntu(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 10),
                          MuscleGroupFamilyChart(frequencyData: muscleGroupFamilyFrequencies, minimized: _minimized),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TRKRInformationContainer(
                      ctaLabel: "Ask for a review",
                      description:
                          "Achieving your fitness goals is easier with a structured plan. Ask the TRKR Coach to optimize your workouts and help you succeed!",
                      onTap: _runRoutineAnalysis),
                  const SizedBox(height: 12),
                  ExerciseLogListView(
                    exerciseLogs: exerciseLogsToViewModels(exerciseLogs: template.exerciseTemplates),
                    previewType: RoutinePreviewType.template,
                  ),
                ],
              ),
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

  void _onMinimiseMuscleGroupSplit() {
    setState(() {
      _minimized = !_minimized;
    });
  }

  void _launchRoutineLogEditor() {
    final template = _template;
    if (template != null) {
      final arguments = RoutineLogArguments(log: template.log(), editorMode: RoutineEditorMode.log);
      navigateToRoutineLogEditor(context: context, arguments: arguments);
    }
  }

  void _createTemplate() async {
    final template = _template;
    if (template != null) {
      _showLoadingScreen();

      try {
        final exercises = template.exerciseTemplates.map((exerciseLog) {
          final uncheckedSets = exerciseLog.sets.map((set) => set.copyWith(checked: false)).toList();

          /// [Exercise.duration] exercises do not have sets in templates
          /// This is because we only need to store the duration of the exercise in [RoutineEditorType.log] i.e data is log in realtime
          final sets = withDurationOnly(type: exerciseLog.exercise.type) ? <SetDto>[] : uncheckedSets;
          return exerciseLog.copyWith(sets: sets);
        }).toList();
        final templateToCreate = RoutineTemplateDto(
            id: "",
            name: template.name,
            notes: template.notes,
            exerciseTemplates: exercises,
            owner: "",
            createdAt: DateTime.now(),
            updatedAt: DateTime.now());

        final createdTemplate = await Provider.of<RoutineTemplateController>(context, listen: false)
            .saveTemplate(templateDto: templateToCreate);
        if (mounted) {
          if (createdTemplate != null) {
            navigateToRoutineTemplatePreview(context: context, template: createdTemplate);
          }
        }
      } catch (_) {
        if (mounted) {
          showSnackbar(
              context: context,
              icon: const Icon(Icons.info_outline),
              message: "Oops, we are unable to create template");
        }
      } finally {
        _hideLoadingScreen();
      }
    }
  }

  void _loadData() {
    final routineTemplateController = Provider.of<RoutineTemplateController>(context, listen: false);
    _template = routineTemplateController.templateWhere(id: widget.id);
    if (_template == null) {
      _loading = true;
      getAPI(endpoint: "/routine-template", queryParameters: {"id": widget.id}).then((data) {
        if (data.isNotEmpty) {
          final json = jsonDecode(data);
          final body = json["data"];
          final routineTemplate = body["getRoutineTemplate"];
          final routineTemplateDto = RoutineTemplate.fromJson(routineTemplate);
          setState(() {
            _loading = false;
            _template = routineTemplateDto.dto();
          });
        }
      });
    }
  }

  void _runRoutineAnalysis() async {
    final template = _template;

    if (template != null) {
      _showLoadingScreen();

      final muscleGroupAndExercises = await _runFunctionMessage(template: template);

      _hideLoadingScreen();

      if (mounted) {
        final originalExerciseTemplates = template.exerciseTemplates.map((template) => template.exercise).toList();
        final exerciseIds = await navigateWithSlideTransition(
                context: context,
                child: TrkrCoachExerciseRecommendationScreen(
                    muscleGroupAndExercises: muscleGroupAndExercises,
                    originalExerciseTemplates: originalExerciseTemplates)) as List<String>? ??
            [];

        if (exerciseIds.isNotEmpty) {
          if (mounted) {
            final exercises = Provider.of<ExerciseController>(context, listen: false).exercises;

            final exerciseTemplates = exerciseIds.map((exerciseId) {
              final exerciseInLibrary = exercises.firstWhere((exercise) => exercise.id == exerciseId);
              final exerciseTemplate = ExerciseLogDto(
                  exerciseInLibrary.id, "", "", exerciseInLibrary, "", [const SetDto(0, 0, false)], DateTime.now(), []);
              return exerciseTemplate;
            }).toList();
            final originalTemplates = template.exerciseTemplates;

            final updatedTemplate = template.copyWith(exerciseTemplates: [...originalTemplates, ...exerciseTemplates]);

            _updateTemplate(template: updatedTemplate);
          }
        }
      }
    }
  }

  Future<List<Map<String, dynamic>>> _runFunctionMessage({required RoutineTemplateDto template}) async {
    List<Map<String, dynamic>> muscleGroupAndExercises = [];

    final listOfExerciseJsons = template.exerciseTemplates
        .map((exerciseTemplate) => jsonEncode({
              "id": exerciseTemplate.exercise.id,
              "name": exerciseTemplate.exercise.name,
            }))
        .toList();

    final StringBuffer buffer = StringBuffer();

    buffer.writeln(
        "For Each Exercise in my selection, recommend an alternative exercise that meets the following criteria.");
    buffer.writeln("\n");
    buffer.writeln("Criteria 1 - Muscle Group Training Requirements:");
    buffer.writeln("Dual Exercises: Ensure each muscle group is trained with two exercises:");
    buffer.writeln("Primary Exercise: One from my original selection.");
    buffer.writeln(
        "Secondary Exercise: A recommended alternative if the original selection doesn't adequately target the muscle group.");
    buffer.writeln("\n");
    buffer.writeln("Criteria 2 - Targeting Specifications:");
    buffer.writeln(
        "Primary or Secondary Focus: Exercises should target the muscle group either primarily or secondarily.");
    buffer.writeln("Range of Motion: Both exercises must engage the muscle group in:");
    buffer.writeln("Lengthened Position");
    buffer.writeln("Shortened Position");
    buffer.writeln("\n");
    buffer.writeln("Exercise Selection:");
    buffer.writeln(listOfExerciseJsons);

    final completeUserInstructions = buffer.toString();

    final tool = await runMessageWithTools(
        systemInstruction: personalTrainerInstructionForWorkouts, userInstruction: completeUserInstructions);
    if (tool != null) {
      final toolId = tool['id'];
      final toolName = tool['name']; // A function
      if (toolName == "list_exercises") {
        if (mounted) {
          final exercises = Provider.of<ExerciseController>(context, listen: false).exercises;
          final functionCallPayload = await createFunctionCallPayload(
              toolId: toolId,
              systemInstruction: personalTrainerInstructionForWorkouts,
              user: completeUserInstructions,
              responseFormat: exercisesRecommendationResponseFormat,
              exercises: exercises);
          final jsonString = await runMessageWithFunctionCallResult(payload: functionCallPayload);
          if (jsonString != null) {
            final json = jsonDecode(jsonString);
            final exercisesJson = json["exercises"] as List<dynamic>;
            muscleGroupAndExercises = exercisesJson.map((json) {
              final muscleGroupString = json["muscle_group"];
              final recommendedExercises = json["recommended_exercises"] as List<dynamic>;
              final rationale = json["rationale"];
              final exerciseTemplates = recommendedExercises.map((exerciseId) {
                return exercises.firstWhere((exercise) => exercise.id == exerciseId);
              }).toList();
              final muscleGroup = MuscleGroup.fromString(muscleGroupString);
              return {
                "muscle_group": muscleGroup,
                "exercises": [exerciseTemplates[0], exerciseTemplates[1]],
                "rationale": rationale
              };
            }).toList();
          }
        }
      } else {
        _showSnackbar("I'm sorry, I cannot assist with that request.");
      }
    }
    return muscleGroupAndExercises;
  }

  void _updateTemplate({required RoutineTemplateDto template}) async {
    await Provider.of<RoutineTemplateController>(context, listen: false).updateTemplate(template: template);
    setState(() {
      _template = template;
    });
  }

  void _showSnackbar(String message) {
    showSnackbar(context: context, icon: const Icon(Icons.info_outline), message: message);
  }

  void _showBottomSheet() {
    final template = _template;

    if (template != null) {
      final workoutLink = "$shareableRoutineUrl/${template.id}";
      final workoutText = copyRoutineAsText(
          routineType: RoutinePreviewType.log,
          name: template.name,
          notes: template.notes,
          exerciseLogs: template.exerciseTemplates);

      displayBottomSheet(
          context: context,
          isScrollControlled: true,
          child: SafeArea(
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const FaIcon(FontAwesomeIcons.link, size: 14, color: Colors.white70),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(workoutLink,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        style: GoogleFonts.ubuntu(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        )),
                  ),
                  const SizedBox(width: 6),
                  OpacityButtonWidget(
                    onPressed: () {
                      HapticFeedback.heavyImpact();
                      final data = ClipboardData(text: workoutLink);
                      Clipboard.setData(data).then((_) {
                        if (mounted) {
                          context.pop();
                          showSnackbar(context: context, icon: const Icon(Icons.check), message: "Workout link copied");
                        }
                      });
                    },
                    label: "Copy",
                    buttonColor: vibrantGreen,
                  )
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: sapphireDark80,
                  border: Border.all(
                    color: sapphireDark80, // Border color
                    width: 1.0, // Border width
                  ),
                  borderRadius: BorderRadius.circular(5), // Optional: Rounded corners
                ),
                child: Text("${workoutText.substring(0, workoutText.length >= 150 ? 150 : workoutText.length)}...",
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.ubuntu(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    )),
              ),
              OpacityButtonWidget(
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  final data = ClipboardData(text: workoutText);
                  Clipboard.setData(data).then((_) {
                    if (mounted) {
                      context.pop();
                      showSnackbar(context: context, icon: const Icon(Icons.check), message: "Workout copied");
                    }
                  });
                },
                label: "Copy as text",
                buttonColor: vibrantGreen,
              )
            ]),
          ));
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }
}

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/appsync/routine_template_plan_dto.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/enums/routine_plan_sessions.dart';
import 'package:tracker_app/enums/routine_plan_weeks.dart';
import 'package:tracker_app/openAI/open_ai_functions.dart';
import 'package:tracker_app/utils/dialog_utils.dart';
import 'package:tracker_app/utils/routine_editors_utils.dart';
import 'package:tracker_app/widgets/dividers/label_container.dart';
import 'package:tracker_app/widgets/pickers/routine_plan_goal_picker.dart';
import 'package:tracker_app/widgets/pickers/routine_plan_weeks_picker.dart';

import '../../colors.dart';
import '../../controllers/exercise_and_routine_controller.dart';
import '../../dtos/appsync/routine_template_dto.dart';
import '../../dtos/abstract_class/exercise_dto.dart';
import '../../dtos/exercise_log_dto.dart';
import '../../enums/routine_plan_goal.dart';
import '../../openAI/open_ai.dart';
import '../../shared_prefs.dart';
import '../../strings/ai_prompts.dart';
import '../../strings/loading_screen_messages.dart';
import '../../widgets/ai_widgets/trkr_coach_widget.dart';
import '../../widgets/backgrounds/trkr_loading_screen.dart';
import '../../widgets/buttons/opacity_button_widget.dart';
import '../../widgets/dividers/center_label_divider.dart';
import '../../widgets/pickers/routine_plan_sessions_picker.dart';

class RoutinePlanEditorScreen extends StatefulWidget {
  static const routeName = '/routine-program-editor';

  const RoutinePlanEditorScreen({super.key});

  @override
  State<RoutinePlanEditorScreen> createState() => _RoutinePlanEditorScreenState();
}

class _RoutinePlanEditorScreenState extends State<RoutinePlanEditorScreen> {
  bool _loading = false;

  RoutinePlanGoal _goal = RoutinePlanGoal.muscle;
  RoutinePlanWeeks _weeks = RoutinePlanWeeks.four;
  RoutinePlanSessions _sessions = RoutinePlanSessions.two;

  final List<MuscleGroup> _selectedMuscleGroups = [MuscleGroup.hamstrings];

  final List<ExerciseDTO> _armsExercises = [];
  final List<ExerciseDTO> _backExercises = [];
  final List<ExerciseDTO> _chestExercises = [];
  final List<ExerciseDTO> _legExercises = [];
  final List<ExerciseDTO> _shoulderExercises = [];

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return TRKRLoadingScreen(
        action: _hideLoadingScreen,
        messages: loadingTRKRCoachRoutineMessages,
      );
    }

    final inactiveStyle = GoogleFonts.ubuntu(color: Colors.white70, fontSize: 22, fontWeight: FontWeight.w600);
    final activeStyle = GoogleFonts.ubuntu(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600);

    final muscleGroupFamilies = MuscleGroup.values
        .map((muscleGroup) => Padding(
              padding: const EdgeInsets.only(right: 8.0, bottom: 6),
              child: OpacityButtonWidget(
                  onPressed: () => _onSelectMuscleGroup(newMuscleGroup: muscleGroup),
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  buttonColor: _getMuscleGroup(muscleGroup: muscleGroup) != null ? vibrantGreen : null,
                  label: muscleGroup.name),
            ))
        .toList();

    final exercisePickers = _selectedMuscleGroups
        .map(
          (muscleGroup) => Padding(
            padding: const EdgeInsets.only(bottom: 2.0),
            child: _FavouriteExercisePicker(
              muscleGroup: muscleGroup,
              inactiveStyle: inactiveStyle,
              activeStyle: activeStyle,
              onSelect: (ExerciseDTO exercise) {
                _onSelectExercise(exercise: exercise, muscleGroup: muscleGroup);
              },
              exercises: _getSelectedExercises(muscleGroup: muscleGroup),
              onRemove: (ExerciseDTO exercise) {
                _onRemoveExercise(exercise: exercise, muscleGroup: muscleGroup);
              },
            ),
          ),
        )
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
          backgroundColor: sapphireDark80,
          leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.squareXmark, color: Colors.white, size: 28),
            onPressed: Navigator.of(context).pop,
          )),
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
          minimum: const EdgeInsets.only(right: 10.0, bottom: 10, left: 10),
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              RichText(
                  text: TextSpan(style: const TextStyle(height: 1.8), children: [
                TextSpan(text: "I want to ", style: inactiveStyle),
                TextSpan(
                    text: "${_goal.description} \n",
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        displayBottomSheet(
                            height: 216, context: context, child: RoutinePlanGoalPicker(onSelect: _onSelectGoal));
                      },
                    style: activeStyle),
                TextSpan(text: "in ", style: inactiveStyle),
                TextSpan(
                    text: "${"${_weeks.weeks} weeks"} \n",
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        displayBottomSheet(
                            height: 216, context: context, child: RoutinePlanWeeksPicker(onSelect: _onSelectWeeks));
                      },
                    style: activeStyle),
                TextSpan(text: "training ", style: inactiveStyle),
                TextSpan(
                    text: "${"${_sessions.frequency} times a week"} \n",
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        displayBottomSheet(
                            context: context,
                            child: RoutinePlanSessionsPicker(onSelect: _onSelectSessions),
                            height: 216);
                      },
                    style: activeStyle),
              ])),
              LabelContainer(
                  label: "Choose muscles to train".toUpperCase(),
                  description: "Choose the muscle groups you’d like to focus on for your training plan.",
                  labelStyle: GoogleFonts.ubuntu(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14),
                  descriptionStyle:
                      GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.white70, fontSize: 14),
                  dividerColor: sapphireLighter),
              const SizedBox(height: 12),
              Wrap(children: muscleGroupFamilies),
              const SizedBox(height: 26),
              LabelContainer(
                  label: "Tell us about your favourite exercises".toUpperCase(),
                  description:
                      "We use your suggestions to deliver smarter, more personalized training recommendations.",
                  labelStyle: GoogleFonts.ubuntu(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14),
                  descriptionStyle:
                      GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.white70, fontSize: 14),
                  dividerColor: sapphireLighter),
              const SizedBox(height: 4),
              ...exercisePickers,
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OpacityButtonWidget(
                    onPressed: _createTemplatePlan,
                    label: "${_goal.description} in ${_weeks.weeks} weeks",
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    buttonColor: vibrantGreen),
              )
            ]),
          ),
        ),
      ),
    );
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

  void _createTemplatePlan() async {
    _showLoadingScreen();

    final StringBuffer buffer = StringBuffer();

    final muscleGroups = _selectedMuscleGroups
        .map((muscleGroup) => muscleGroup.name)
        .join(", ");

    buffer.writeln();

    buffer.writeln(
        "I want to ${_goal.description} over a ${_weeks.weeks}-week period. The muscle groups I want to focus on are $muscleGroups.");
    for (final family in _selectedMuscleGroups) {
      final selectedExerciseNames = _getSelectedExercises(muscleGroup: family).map((exercise) => exercise.name).join(", ");
      if (selectedExerciseNames.isNotEmpty) {
        buffer.writeln("For ${family.name}, I prefer exercises like $selectedExerciseNames");
      }
    }

    buffer.writeln();

    buffer.writeln("Instructions");
    buffer
        .writeln("1. Create ${_sessions.frequency} workouts to be reused for the entire ${_weeks.weeks}-week period .");
    buffer.writeln("2. For each muscle group, suggest exercises that are sufficient.");
    buffer.writeln(
        "3. Suggest a balanced combination of exercises engaging all muscle groups from both the lengthened and shortened positions.");
    buffer.writeln(
        "4. Ensure variety while sticking to exercises similar in nature to the exercise ids listed above if any.");

    final completeInstructions = buffer.toString();

    await _runFunctionMessage(userInstruction: completeInstructions);

    _hideLoadingScreen();

    if (mounted) {
      context.pop();
    }
  }

  Future<void> _runFunctionMessage({required String userInstruction}) async {
    final tool = await runMessageWithTools(
        systemInstruction: personalTrainerInstructionForWorkouts,
        userInstruction: userInstruction,
        callback: (message) {
          showSnackbar(context: context, message: "Oops, unable to assist with this request.", icon: TRKRCoachWidget());
        });
    if (tool != null) {
      final toolId = tool['id'];
      final toolName = tool['name']; // A function
      if (toolName == "list_exercises") {
        if (mounted) {
          final controller = Provider.of<ExerciseAndRoutineController>(context, listen: false);
          final exercises = controller.exercises;
          final functionCallPayload = await createFunctionCallPayload(
              toolId: toolId,
              systemInstruction: personalTrainerInstructionForWorkouts,
              user: userInstruction,
              responseFormat: newRoutinePlanResponseFormat,
              exercises: exercises);
          final jsonString = await runMessageWithFunctionCallResult(payload: functionCallPayload);
          if (jsonString != null) {
            final json = jsonDecode(jsonString);
            final workouts = json["workouts"] as List<dynamic>;
            final workoutPlanName = json["workout_plan_name"] ?? "A workout plan";
            final workoutPlanNotes = json["workout_plan_caption"] ?? "";
            final routineTemplateDtos = _createRoutineTemplates(workouts: workouts, exercises: exercises);
            final routineTemplatePlanDto = RoutineTemplatePlanDto(
                id: "",
                name: workoutPlanName,
                notes: workoutPlanNotes,
                weeks: _weeks.weeks,
                owner: "",
                createdAt: DateTime.now(),
                updatedAt: DateTime.now());
            _saveTemplatePlan(templatePlanDto: routineTemplatePlanDto, templateDtos: routineTemplateDtos);
          }
        }
      } else {
        if (mounted) {
          showSnackbar(context: context, message: "Oops, unable to assist with this request.", icon: TRKRCoachWidget());
        }
      }
    }
  }

  void _onSelectGoal(RoutinePlanGoal goal) {
    Navigator.of(context).pop();
    setState(() {
      _goal = goal;
    });
  }

  void _onSelectWeeks(RoutinePlanWeeks weeks) {
    Navigator.of(context).pop();
    setState(() {
      _weeks = weeks;
    });
  }

  void _onSelectSessions(RoutinePlanSessions sessions) {
    Navigator.of(context).pop();
    setState(() {
      _sessions = sessions;
    });
  }

  void _onSelectMuscleGroup({required MuscleGroup newMuscleGroup}) {
    final oldFamily = _selectedMuscleGroups.firstWhereOrNull((previousFamily) => previousFamily == newMuscleGroup);
    setState(() {
      if (oldFamily != null) {
        _selectedMuscleGroups.remove(oldFamily);
      } else {
        _selectedMuscleGroups.add(newMuscleGroup);
      }
    });
  }

  MuscleGroup? _getMuscleGroup({required MuscleGroup muscleGroup}) =>
      _selectedMuscleGroups.firstWhereOrNull((previousFamily) => previousFamily == muscleGroup);

  List<ExerciseDTO> _getSelectedExercises({required MuscleGroup muscleGroup}) {
    return switch (muscleGroup) {
      MuscleGroup.biceps => _armsExercises,
      MuscleGroup.back => _backExercises,
      MuscleGroup.chest => _chestExercises,
      MuscleGroup.quadriceps => _legExercises,
      MuscleGroup.shoulders => _shoulderExercises,
      // TODO: Handle this case.
      MuscleGroup.abs => throw UnimplementedError(),
      // TODO: Handle this case.
      MuscleGroup.abductors => throw UnimplementedError(),
      // TODO: Handle this case.
      MuscleGroup.adductors => throw UnimplementedError(),
      // TODO: Handle this case.
      MuscleGroup.calves => throw UnimplementedError(),
      // TODO: Handle this case.
      MuscleGroup.glutes => throw UnimplementedError(),
      // TODO: Handle this case.
      MuscleGroup.hamstrings => throw UnimplementedError(),
      // TODO: Handle this case.
      MuscleGroup.triceps => throw UnimplementedError(),
    };
  }

  void _onSelectExercise({required MuscleGroup muscleGroup, required ExerciseDTO exercise}) {
    // switch (muscleGroup) {
    //   case MuscleGroupFamily.arms:
    //     _armsExercises.add(exercise);
    //     break;
    //   case MuscleGroupFamily.back:
    //     _backExercises.add(exercise);
    //     break;
    //   case MuscleGroupFamily.chest:
    //     _chestExercises.add(exercise);
    //     break;
    //   case MuscleGroupFamily.core:
    //     _coreExercises.add(exercise);
    //     break;
    //   case MuscleGroupFamily.legs:
    //     _legExercises.add(exercise);
    //     break;
    //   case MuscleGroupFamily.neck:
    //     _neckExercises.add(exercise);
    //     break;
    //   case MuscleGroupFamily.shoulders:
    //     _shoulderExercises.add(exercise);
    //     break;
    //   default:
    //     throw UnsupportedError("${muscleGroup.name} is not allowed in here");
    // }
    setState(() {});
  }

  void _onRemoveExercise({required MuscleGroup muscleGroup, required ExerciseDTO exercise}) {
    // switch (muscleGroup) {
    //   case MuscleGroupFamily.arms:
    //     _armsExercises.remove(exercise);
    //     break;
    //   case MuscleGroupFamily.back:
    //     _backExercises.remove(exercise);
    //     break;
    //   case MuscleGroupFamily.chest:
    //     _chestExercises.remove(exercise);
    //     break;
    //   case MuscleGroupFamily.core:
    //     _coreExercises.remove(exercise);
    //     break;
    //   case MuscleGroupFamily.legs:
    //     _legExercises.remove(exercise);
    //     break;
    //   case MuscleGroupFamily.shoulders:
    //     _shoulderExercises.remove(exercise);
    //     break;
    //   default:
    //     throw UnsupportedError("${family.name} is not allowed in here");
    // }
    setState(() {});
  }

  List<RoutineTemplateDto> _createRoutineTemplates(
      {required List<dynamic> workouts, required List<ExerciseDTO> exercises}) {
    return workouts.map((workout) {
      final workoutName = workout["workout_name"] ?? "A workout";
      final workoutCaption = workout["workout_caption"] ?? "A workout created by TRKR Coach";
      final exerciseNames = workout["exercises"] as List<dynamic>;
      final exerciseTemplates = exerciseNames.map((exerciseName) {
        final exerciseInLibrary = exercises.firstWhere((exercise) => exercise.name == exerciseName);
        final exerciseTemplate = ExerciseLogDTO.empty(exercise: exerciseInLibrary);
        return exerciseTemplate;
      }).toList();
      return RoutineTemplateDto(
          id: "",
          name: workoutName,
          exerciseTemplates: exerciseTemplates,
          notes: workoutCaption,
          owner: SharedPrefs().userId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now());
    }).toList();
  }

  Future<void> _saveTemplatePlan(
      {required RoutineTemplatePlanDto templatePlanDto, required List<RoutineTemplateDto> templateDtos}) async {
    final controller = Provider.of<ExerciseAndRoutineController>(context, listen: false);
    final templatePlan = await controller.saveTemplatePlan(templatePlanDto: templatePlanDto);
    for (final templateDto in templateDtos) {
      await controller.saveTemplate(templatePlan: templatePlan, templateDto: templateDto);
    }
  }

  @override
  void initState() {
    super.initState();
  }
}

class _FavouriteExercisePicker extends StatelessWidget {
  final MuscleGroup muscleGroup;
  final TextStyle inactiveStyle;
  final TextStyle activeStyle;
  final Function(ExerciseDTO exercise) onSelect;
  final Function(ExerciseDTO exercise) onRemove;
  final List<ExerciseDTO> exercises;

  const _FavouriteExercisePicker(
      {required this.muscleGroup,
      required this.inactiveStyle,
      required this.activeStyle,
      required this.onSelect,
      required this.exercises,
      required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final listTiles = exercises
        .map((exercise) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(exercise.name,
                      style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15)),
                  trailing: GestureDetector(
                      onTap: () => onRemove(exercise),
                      child: FaIcon(FontAwesomeIcons.squareXmark, color: Colors.redAccent, size: 22)),
                ),
                Divider(
                  color: sapphireLighter,
                )
              ],
            ))
        .toList();

    return GestureDetector(
      onTap: () {
        showExercisesInLibrary(
            context: context,
            exercisesToExclude: exercises.map((exercise) => exercise.name).toList(),
            muscleGroup: muscleGroup,
            onSelected: (exercises) {
              for (final exercise in exercises) {
                onSelect(exercise);
              }
            });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              child: CenterLabelDivider(
                  label: muscleGroup.name.toUpperCase(),
                  style: GoogleFonts.ubuntu(fontWeight: FontWeight.w900, color: Colors.white70, fontSize: 16),
                  dividerColor: sapphireLighter)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(right: 20.0, bottom: 20, left: 20, top: 12),
            decoration: BoxDecoration(
              border: Border.all(
                style: BorderStyle.solid,
                color: sapphireLighter, // Border color
                width: 1.0, // Border width
              ),
              borderRadius: BorderRadius.circular(5), // Rounded corners
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...listTiles,
                if (exercises.isNotEmpty) const SizedBox(height: 10),
                Center(
                  child: RichText(
                      text: TextSpan(children: [
                    TextSpan(text: "Tap to select", style: inactiveStyle.copyWith(fontSize: 14)),
                    TextSpan(text: " ", style: activeStyle),
                    TextSpan(text: muscleGroup.name, style: activeStyle.copyWith(fontSize: 14)),
                    TextSpan(text: " ", style: activeStyle),
                    TextSpan(text: "exercises", style: inactiveStyle.copyWith(fontSize: 14)),
                  ])),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

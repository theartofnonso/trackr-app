import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/dtos/appsync/exercise_dto.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/enums/routine_plan_sessions.dart';
import 'package:tracker_app/enums/routine_plan_weeks.dart';
import 'package:tracker_app/utils/dialog_utils.dart';
import 'package:tracker_app/utils/routine_editors_utils.dart';
import 'package:tracker_app/widgets/dividers/label_container.dart';
import 'package:tracker_app/widgets/pickers/routine_plan_goal_picker.dart';
import 'package:tracker_app/widgets/pickers/routine_plan_weeks_picker.dart';

import '../../colors.dart';
import '../../enums/routine_plan_goal.dart';
import '../../strings/ai_prompts.dart';
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

  final List<MuscleGroupFamily> _selectedMuscleGroupFamilies = [MuscleGroupFamily.legs];

  final List<ExerciseDto> _armsExercises = [];
  final List<ExerciseDto> _backExercises = [];
  final List<ExerciseDto> _chestExercises = [];
  final List<ExerciseDto> _coreExercises = [];
  final List<ExerciseDto> _legExercises = [];
  final List<ExerciseDto> _neckExercises = [];
  final List<ExerciseDto> _shoulderExercises = [];

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return TRKRLoadingScreen(
        action: _hideLoadingScreen,
        messages: [
          "Crafting your perfect plan",
          "Tailoring your plan just for you",
          "Sweating the details for you",
          "One step closer to your goals"
        ],
      );
    }

    final inactiveStyle = GoogleFonts.ubuntu(color: Colors.white70, fontSize: 22, fontWeight: FontWeight.w600);
    final activeStyle = GoogleFonts.ubuntu(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600);

    final muscleGroupFamilies = MuscleGroupFamily.values
        .map((family) => Padding(
              padding: const EdgeInsets.only(right: 8.0, bottom: 6),
              child: OpacityButtonWidget(
                  onPressed: () => _onSelectMuscleGroupFamily(newFamily: family),
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  buttonColor: _getMuscleGroupFamily(family: family) != null ? vibrantGreen : null,
                  label: family.name),
            ))
        .toList();

    final exercisePickers = _selectedMuscleGroupFamilies
        .map(
          (family) => Padding(
            padding: const EdgeInsets.only(bottom: 2.0),
            child: _FavouriteExercisePicker(
              family: family,
              inactiveStyle: inactiveStyle,
              activeStyle: activeStyle,
              onSelect: (ExerciseDto exercise) {
                _onSelectExercise(exercise: exercise, family: family);
              },
              exercises: _getSelectedExercises(family: family),
              onRemove: (ExerciseDto exercise) {
                _onRemoveExercise(exercise: exercise, family: family);
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
                    onPressed: _createWorkoutPlan,
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

  void _createWorkoutPlan() {
    _showLoadingScreen();

    final StringBuffer buffer = StringBuffer();

    final muscleGroups = _selectedMuscleGroupFamilies
        .map((family) => MuscleGroup.byFamily(family))
        .expand((muscleGroups) => muscleGroups)
        .map((muscleGroup) => muscleGroup.name)
        .join(", ");

    buffer.writeln();

    buffer.writeln("I want to ${_goal.description} over a ${_weeks.weeks} weeks period. The muscle groups I want to focus on are $muscleGroups.");
    for (final family in _selectedMuscleGroupFamilies) {
      final selectedExerciseIds = _getSelectedExercises(family: family).map((exercise) => exercise.id).join(", ");
      if(selectedExerciseIds.isNotEmpty) {
        buffer.writeln("For ${family.name}, I prefer exercises like $selectedExerciseIds");
      }
    }
    buffer.writeln();

    buffer.writeln("Instruction");
    buffer.writeln(personalTrainerInstructionForWorkouts);

    buffer.writeln();

    buffer.writeln("Task");
    buffer.writeln(
        "1. Create a ${_weeks.weeks}-week ${_goal.description} workout plan with ${_sessions.frequency} training sessions per week.");
    buffer.writeln("2. For each muscle group, suggest exercises that are sufficient.");
    buffer.writeln("3. Suggest a balanced combination of exercises engaging all muscle groups from both the lengthened and shortened positions.");
    buffer.writeln(
        "4. Ensure variety while sticking to exercises similar in nature to the exercise ids listed above if any.");

    final completeInstructions = buffer.toString();

    _hideLoadingScreen();
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

  void _onSelectMuscleGroupFamily({required MuscleGroupFamily newFamily}) {
    final oldFamily = _selectedMuscleGroupFamilies.firstWhereOrNull((previousFamily) => previousFamily == newFamily);
    setState(() {
      if (oldFamily != null) {
        _selectedMuscleGroupFamilies.remove(oldFamily);
      } else {
        _selectedMuscleGroupFamilies.add(newFamily);
      }
    });
  }

  MuscleGroupFamily? _getMuscleGroupFamily({required MuscleGroupFamily family}) =>
      _selectedMuscleGroupFamilies.firstWhereOrNull((previousFamily) => previousFamily == family);

  List<ExerciseDto> _getSelectedExercises({required MuscleGroupFamily family}) {
    return switch (family) {
      MuscleGroupFamily.arms => _armsExercises,
      MuscleGroupFamily.back => _backExercises,
      MuscleGroupFamily.chest => _chestExercises,
      MuscleGroupFamily.core => _coreExercises,
      MuscleGroupFamily.legs => _legExercises,
      MuscleGroupFamily.neck => _neckExercises,
      MuscleGroupFamily.shoulders => _shoulderExercises,
      _ => throw UnsupportedError("${family.name} is not allowed in here"),
    };
  }

  void _onSelectExercise({required MuscleGroupFamily family, required ExerciseDto exercise}) {
    switch (family) {
      case MuscleGroupFamily.arms:
        _armsExercises.add(exercise);
        break;
      case MuscleGroupFamily.back:
        _backExercises.add(exercise);
        break;
      case MuscleGroupFamily.chest:
        _chestExercises.add(exercise);
        break;
      case MuscleGroupFamily.core:
        _coreExercises.add(exercise);
        break;
      case MuscleGroupFamily.legs:
        _legExercises.add(exercise);
        break;
      case MuscleGroupFamily.neck:
        _neckExercises.add(exercise);
        break;
      case MuscleGroupFamily.shoulders:
        _shoulderExercises.add(exercise);
        break;
      default:
        throw UnsupportedError("${family.name} is not allowed in here");
    }
    setState(() {});
  }

  void _onRemoveExercise({required MuscleGroupFamily family, required ExerciseDto exercise}) {
    switch (family) {
      case MuscleGroupFamily.arms:
        _armsExercises.remove(exercise);
        break;
      case MuscleGroupFamily.back:
        _backExercises.remove(exercise);
        break;
      case MuscleGroupFamily.chest:
        _chestExercises.remove(exercise);
        break;
      case MuscleGroupFamily.core:
        _coreExercises.remove(exercise);
        break;
      case MuscleGroupFamily.legs:
        _legExercises.remove(exercise);
        break;
      case MuscleGroupFamily.shoulders:
        _shoulderExercises.remove(exercise);
        break;
      default:
        throw UnsupportedError("${family.name} is not allowed in here");
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }
}

class _FavouriteExercisePicker extends StatelessWidget {
  final MuscleGroupFamily family;
  final TextStyle inactiveStyle;
  final TextStyle activeStyle;
  final Function(ExerciseDto exercise) onSelect;
  final Function(ExerciseDto exercise) onRemove;
  final List<ExerciseDto> exercises;

  const _FavouriteExercisePicker(
      {required this.family,
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
            excludeExercises: exercises,
            muscleGroupFamily: family,
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
                  label: family.name.toUpperCase(),
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
                    TextSpan(text: family.name, style: activeStyle.copyWith(fontSize: 14)),
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

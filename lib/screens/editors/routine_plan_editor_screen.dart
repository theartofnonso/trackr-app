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
import 'package:tracker_app/widgets/label_divider.dart';
import 'package:tracker_app/widgets/pickers/routine_plan_goal_picker.dart';
import 'package:tracker_app/widgets/pickers/routine_plan_weeks_picker.dart';

import '../../colors.dart';
import '../../enums/routine_plan_goal.dart';
import '../../widgets/buttons/opacity_button_widget.dart';
import '../../widgets/information_containers/information_container.dart';
import '../../widgets/pickers/routine_plan_sessions_picker.dart';

class RoutinePlanEditorScreen extends StatefulWidget {
  static const routeName = '/routine-program-editor';

  const RoutinePlanEditorScreen({super.key});

  @override
  State<RoutinePlanEditorScreen> createState() => _RoutinePlanEditorScreenState();
}

class _RoutinePlanEditorScreenState extends State<RoutinePlanEditorScreen> {
  RoutinePlanGoal _goal = RoutinePlanGoal.muscle;
  RoutinePlanWeeks _weeks = RoutinePlanWeeks.four;
  RoutinePlanSessions _sessions = RoutinePlanSessions.two;

  final List<MuscleGroupFamily> _selectedMuscleGroupFamilies = [MuscleGroupFamily.fullBody];

  final List<ExerciseDto> _armsExercises = [];
  final List<ExerciseDto> _backExercises = [];
  final List<ExerciseDto> _chestExercises = [];
  final List<ExerciseDto> _coreExercises = [];
  final List<ExerciseDto> _fullBodyExercises = [];
  final List<ExerciseDto> _legExercises = [];
  final List<ExerciseDto> _shoulderExercises = [];

  @override
  Widget build(BuildContext context) {
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

    final exercisePickers = MuscleGroupFamily.values
        .map(
          (family) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _ExercisePicker(
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
            icon: const FaIcon(FontAwesomeIcons.solidCircleXmark, color: Colors.white, size: 28),
            onPressed: Navigator.of(context).pop,
          )),
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
              LabelDivider(
                  label: "Choose muscles to train",
                  shouldCapitalise: true,
                  labelColor: Colors.white,
                  dividerColor: sapphireLighter),
              const SizedBox(height: 12),
              Wrap(children: muscleGroupFamilies),
              const SizedBox(height: 18),
              LabelDivider(
                  label: "Tell us about your favourite exercises",
                  shouldCapitalise: true,
                  labelColor: Colors.white,
                  dividerColor: sapphireLighter),
              const SizedBox(height: 14),
              ...exercisePickers,
              const SizedBox(height: 14),
              InformationContainer(
                leadingIcon: FaIcon(FontAwesomeIcons.lightbulb, size: 16),
                title: 'Workout Plan Info',
                description: "Provide TRKR Coach with answers that are closely accurate to what your goals are.",
                color: Colors.transparent,
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OpacityButtonWidget(
                    onPressed: () {},
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
      if (newFamily == MuscleGroupFamily.fullBody) {
        _selectedMuscleGroupFamilies.clear();
        _selectedMuscleGroupFamilies.add(newFamily);
      } else if (oldFamily != null) {
        _selectedMuscleGroupFamilies.remove(oldFamily);
      } else {
        _selectedMuscleGroupFamilies.add(newFamily);
        final fullBody = _getMuscleGroupFamily(family: MuscleGroupFamily.fullBody);
        if (fullBody != null) {
          _selectedMuscleGroupFamilies.remove(MuscleGroupFamily.fullBody);
        }
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
      MuscleGroupFamily.fullBody => _fullBodyExercises,
      MuscleGroupFamily.legs => _legExercises,
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
      case MuscleGroupFamily.fullBody:
        _fullBodyExercises.add(exercise);
        break;
      case MuscleGroupFamily.legs:
        _legExercises.add(exercise);
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
      case MuscleGroupFamily.fullBody:
        _fullBodyExercises.remove(exercise);
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

class _ExercisePicker extends StatelessWidget {
  final MuscleGroupFamily family;
  final TextStyle inactiveStyle;
  final TextStyle activeStyle;
  final Function(ExerciseDto exercise) onSelect;
  final Function(ExerciseDto exercise) onRemove;
  final List<ExerciseDto> exercises;

  const _ExercisePicker(
      {required this.family,
      required this.inactiveStyle,
      required this.activeStyle,
      required this.onSelect,
      required this.exercises,
      required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final listTiles = exercises
        .map((exercise) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(exercise.name,
                  style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15)),
              trailing: GestureDetector(
                  onTap: () => onRemove(exercise),
                  child: FaIcon(FontAwesomeIcons.solidCircleXmark, color: Colors.redAccent, size: 22)),
            ))
        .toList();

    return GestureDetector(
      onTap: () {
        showExercisesInLibrary(
            context: context,
            excludeExercises: exercises,
            onSelected: (exercises) {
              for (final exercise in exercises) {
                onSelect(exercise);
              }
            });
      },
      child: Container(
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
            ...listTiles
          ],
        ),
      ),
    );
  }
}

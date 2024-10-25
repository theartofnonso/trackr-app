import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/controllers/exercise_controller.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/enums/training_position_enum.dart';
import 'package:tracker_app/screens/exercise/muscle_groups_screen.dart';
import 'package:tracker_app/utils/dialog_utils.dart';

import '../../colors.dart';
import '../../dtos/exercise_dto.dart';
import '../../enums/exercise_type_enums.dart';
import '../../widgets/buttons/opacity_button_widget.dart';
import '../../widgets/information_containers/information_container.dart';
import '../exercise/exercise_type_screen.dart';

class ExerciseEditorScreen extends StatefulWidget {
  static const routeName = '/exercise-editor';

  final ExerciseDto? exercise;

  const ExerciseEditorScreen({super.key, this.exercise});

  @override
  State<ExerciseEditorScreen> createState() => _ExerciseEditorScreenState();
}

class _ExerciseEditorScreenState extends State<ExerciseEditorScreen> {
  String? _exerciseName;

  late MuscleGroup _primaryMuscleGroup;
  late ExerciseType _exerciseType;

  bool _isInputFieldVisible = false;

  @override
  Widget build(BuildContext context) {
    final exerciseEditorController = Provider.of<ExerciseController>(context, listen: true);

    if (exerciseEditorController.errorMessage.isNotEmpty) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _showSnackbar(exerciseEditorController.errorMessage);
      });
    }

    final exercise = widget.exercise;

    final inactiveStyle = GoogleFonts.ubuntu(color: Colors.white70, fontSize: 22, fontWeight: FontWeight.w600);
    final activeStyle = GoogleFonts.ubuntu(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600);

    return PopScope(
        canPop: false,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: sapphireDark80,
            leading: IconButton(
              icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
              onPressed: context.pop,
            ),
            actions: [
              exercise != null
                  ? GestureDetector(
                      onTap: _updateExercise,
                      child: Text("Update",
                          style: GoogleFonts.ubuntu(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white)))
                  : const SizedBox.shrink(),
              const SizedBox(width: 12)
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
              minimum: const EdgeInsets.all(10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RichText(
                      text: TextSpan(style: const TextStyle(height: 2.0), children: [
                    TextSpan(text: "Train ", style: inactiveStyle),
                    TextSpan(
                        text: "${_primaryMuscleGroup.name} \n",
                        recognizer: TapGestureRecognizer()..onTap = _navigateToMuscleGroupsScreen,
                        style: activeStyle),
                    TextSpan(text: "with ", style: inactiveStyle),
                    TextSpan(
                        text: "${_exerciseName ?? "exercise name"} \n",
                        recognizer: TapGestureRecognizer()..onTap = _showInputTextField,
                        style: activeStyle),
                    TextSpan(text: "using ", style: inactiveStyle),
                    TextSpan(
                        text: _exerciseType.name,
                        recognizer: TapGestureRecognizer()..onTap = _navigateToExerciseTypeScreen,
                        style: exercise == null ? activeStyle : inactiveStyle),
                  ])),
                ),
                const Spacer(),
                if (!_isInputFieldVisible)
                  const Column(children: [
                    InformationContainer(
                        leadingIcon: FaIcon(FontAwesomeIcons.lightbulb, size: 16),
                        title: 'Tip',
                        description: "Tap text in white to edit.\nExercise type is not editable once created.",
                        color: Colors.transparent),
                    SizedBox(height: 20),
                  ]),
                if (!_isInputFieldVisible && _exerciseName != null && exercise == null)
                  SizedBox(
                    width: double.infinity,
                    child: OpacityButtonWidget(
                        onPressed: _createExercise,
                        label: "Create Exercise",
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        buttonColor: vibrantGreen),
                  ),
              ]),
            ),
          ),
        ));
  }

  void _showSnackbar(String message) {
    showSnackbar(context: context, icon: const Icon(Icons.info_outline), message: message);
  }

  void _navigateToMuscleGroupsScreen() async {
    final muscleGroup = await Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => MuscleGroupsScreen(previousMuscleGroup: _primaryMuscleGroup)))
        as MuscleGroup?;

    if (muscleGroup != null) {
      setState(() {
        _primaryMuscleGroup = muscleGroup;
      });
    }
  }

  void _navigateToExerciseTypeScreen() async {
    if (widget.exercise != null) return;

    /// We don't want to allow editing of exercise type once created.
    final type = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ExerciseTypeScreen()))
        as ExerciseType?;
    if (type != null) {
      setState(() {
        _exerciseType = type;
      });
    }
  }

  void _updateExerciseName(String? value) {
    if (value == null) return;
    setState(() {
      _exerciseName = value.trim();
    });
  }

  void _doneTyping() {
    setState(() {
      _isInputFieldVisible = false;
    });
  }

  void _showInputTextField() async {
    setState(() {
      _isInputFieldVisible = true;
    });

    await showModalBottomSheet(
        context: context,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
                padding: const EdgeInsets.only(top: 16, right: 16, bottom: 28, left: 16),
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        sapphireDark80,
                        sapphireDark,
                      ],
                    )),
                child: TextField(
                  controller: TextEditingController(text: _exerciseName),
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5), borderSide: const BorderSide(color: sapphireLighter)),
                      filled: true,
                      fillColor: sapphireDark,
                      hintText: "Enter exercise name",
                      hintStyle: GoogleFonts.ubuntu(color: Colors.grey, fontSize: 14)),
                  onChanged: (value) => _updateExerciseName(value),
                  cursorColor: Colors.white,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  style: GoogleFonts.ubuntu(
                      fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.8), fontSize: 14),
                )),
          );
        });
    _doneTyping();
  }

  void _createExercise() async {
    final exerciseName = _exerciseName;

    if (exerciseName == null) return;

    if (exerciseName.isEmpty) {
      _showSnackbar("Please provide a name for this exercise");
    } else {
      final exercise = ExerciseDto(
          id: "",
          name: exerciseName,
          primaryMuscleGroup: _primaryMuscleGroup,
          secondaryMuscleGroups: [],
          trainingPosition: TrainingPosition.none,
          type: _exerciseType,
          owner: "");

      await Provider.of<ExerciseController>(context, listen: false).saveExercise(exerciseDto: exercise);
      if (mounted) {
        context.pop();
      }
    }
  }

  void _updateExercise() async {
    final exerciseName = _exerciseName;

    if (exerciseName == null) return;

    if (exerciseName.isEmpty) {
      _showSnackbar("Please provide a name for this exercise");
    } else {
      final exercise = widget.exercise;
      if (exercise == null) return;

      final updatedExercise = exercise.copyWith(name: exerciseName.trim(), primaryMuscleGroup: _primaryMuscleGroup);
      await Provider.of<ExerciseController>(context, listen: false).updateExercise(exercise: updatedExercise);
      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  void initState() {
    super.initState();

    final previousExercise = widget.exercise;

    _primaryMuscleGroup = previousExercise != null ? previousExercise.primaryMuscleGroup : MuscleGroup.values.first;

    _exerciseType = previousExercise != null ? previousExercise.type : ExerciseType.weights;

    _exerciseName = previousExercise?.name;
  }
}

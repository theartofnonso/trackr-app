import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/screens/exercise/muscle_groups_screen.dart';
import 'package:tracker_app/utils/dialog_utils.dart';

import '../../colors.dart';
import '../../controllers/exercise_and_routine_controller.dart';
import '../../dtos/appsync/exercise_dto.dart';
import '../../enums/exercise_type_enums.dart';
import '../../logger.dart';
import '../../utils/general_utils.dart';
import '../../widgets/buttons/opacity_button_widget.dart';
import '../../widgets/dividers/label_divider.dart';
import '../exercise/exercise_type_screen.dart';

class ExerciseEditorScreen extends StatefulWidget {
  static const routeName = '/exercise-editor';

  final ExerciseDto? exercise;

  const ExerciseEditorScreen({super.key, this.exercise});

  @override
  State<ExerciseEditorScreen> createState() => _ExerciseEditorScreenState();
}

class _ExerciseEditorScreenState extends State<ExerciseEditorScreen> {
  late MuscleGroup _primaryMuscleGroup;
  late ExerciseType _exerciseType;

  final logger = getLogger(className: "_ExerciseEditorScreenState");

  late TextEditingController _exerciseNameController;

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final exerciseEditorController = Provider.of<ExerciseAndRoutineController>(context, listen: true);

    if (exerciseEditorController.errorMessage.isNotEmpty) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _showSnackbar(exerciseEditorController.errorMessage);
      });
    }

    final exercise = widget.exercise;

    return PopScope(
        canPop: false,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const FaIcon(
                FontAwesomeIcons.squareXmark,
                size: 28,
              ),
              onPressed: context.pop,
            ),
            title: Text(exercise?.name ?? "Create New Exercise".toUpperCase()),
            centerTitle: true,
            actions: [
              exercise != null
                  ? IconButton(
                      icon: const FaIcon(FontAwesomeIcons.solidSquareCheck, size: 28),
                      onPressed: _updateExercise,
                    )
                  : const SizedBox.shrink(),
              const SizedBox(width: 12)
            ],
          ),
          body: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: themeGradient(context: context),
            ),
            child: SafeArea(
              minimum: const EdgeInsets.all(10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                TextField(
                  controller: _exerciseNameController,
                  decoration: InputDecoration(
                    hintText: "Exercise Name",
                  ),
                  cursorColor: isDarkMode ? Colors.white : Colors.black,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  style: GoogleFonts.ubuntu(
                      fontWeight: FontWeight.w400, color: isDarkMode ? Colors.white : Colors.black, fontSize: 14),
                ),
                const SizedBox(height: 20),
                LabelDivider(
                  label: "Select muscle group to train".toUpperCase(),
                  labelColor: isDarkMode ? Colors.white : Colors.black,
                  dividerColor: sapphireLighter,
                  fontSize: 14,
                ),
                const SizedBox(height: 8),
                Text("Choose from a list of muscle groups to train for this custom exercise.",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w400, color: isDarkMode ? Colors.white70 : Colors.black)),
                const SizedBox(height: 2),
                OpacityButtonWidget(label: _primaryMuscleGroup.name, onPressed: _navigateToMuscleGroupsScreen),
                const SizedBox(height: 4),
                if (exercise == null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      LabelDivider(
                        label: "Choose how to log this exercise".toUpperCase(),
                        labelColor: isDarkMode ? Colors.white : Colors.black,
                        dividerColor: sapphireLighter,
                        fontSize: 14,
                      ),
                      const SizedBox(height: 8),
                      Text("You can log this exercise using reps only, reps and weights or duration.",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w400, color: isDarkMode ? Colors.white70 : Colors.black)),
                      const SizedBox(height: 2),
                      OpacityButtonWidget(label: _exerciseType.name, onPressed: _navigateToExerciseTypeScreen),
                    ],
                  ),
                const Spacer(),
                if (exercise == null)
                  SafeArea(
                    minimum: EdgeInsets.all(10),
                    child: SizedBox(
                      width: double.infinity,
                      child: OpacityButtonWidget(
                          onPressed: _createExercise,
                          label: "Create Exercise",
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          buttonColor: vibrantGreen),
                    ),
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
    if (widget.exercise != null) {
      showSnackbar(
          context: context,
          icon: FaIcon(FontAwesomeIcons.circleInfo),
          message: "Exercise type cannot be changed after creation.");
      return;
    }

    /// We don't want to allow editing of exercise type once created.
    final type = await Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => ExerciseTypeScreen(exerciseType: _exerciseType)))
        as ExerciseType?;
    if (type != null) {
      setState(() {
        _exerciseType = type;
      });
    }
  }

  void _createExercise() async {
    final exerciseName = _exerciseNameController.text.trim();

    if (exerciseName.isEmpty) return;

    if (exerciseName.isEmpty) {
      _showSnackbar("Please provide a name for this exercise");
    } else {
      final exercise = ExerciseDto(
          id: "",
          name: exerciseName,
          primaryMuscleGroup: _primaryMuscleGroup,
          secondaryMuscleGroups: [],
          type: _exerciseType,
          owner: "");

      await Provider.of<ExerciseAndRoutineController>(context, listen: false).saveExercise(exerciseDto: exercise);

      logger.i("created exercise ${exercise.toString()}");
      if (mounted) {
        context.pop();
      }
    }
  }

  void _updateExercise() async {
    final exerciseName = _exerciseNameController.text.trim();

    if (exerciseName.isEmpty) return;

    if (exerciseName.isEmpty) {
      _showSnackbar("Please provide a name for this exercise");
    } else {
      final exercise = widget.exercise;
      if (exercise == null) return;

      final exerciseToBeUpdated = exercise.copyWith(name: exerciseName.trim(), primaryMuscleGroup: _primaryMuscleGroup);
      await Provider.of<ExerciseAndRoutineController>(context, listen: false)
          .updateExercise(exercise: exerciseToBeUpdated);

      if (mounted) {
        context.pop(exerciseToBeUpdated);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    final previousExercise = widget.exercise;

    _exerciseNameController = TextEditingController(text: previousExercise?.name);

    _primaryMuscleGroup = previousExercise != null ? previousExercise.primaryMuscleGroup : MuscleGroup.values.first;

    _exerciseType = previousExercise != null ? previousExercise.type : ExerciseType.weights;
  }
}

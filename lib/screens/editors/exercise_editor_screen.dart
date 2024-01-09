import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/providers/exercise_provider.dart';
import 'package:tracker_app/screens/exercise/muscle_groups_screen.dart';
import 'package:tracker_app/utils/string_utils.dart';
import 'package:tracker_app/widgets/helper_widgets/dialog_helper.dart';

import '../../app_constants.dart';
import '../../dtos/exercise_dto.dart';
import '../../enums/exercise_type_enums.dart';
import '../../widgets/buttons/text_button_widget.dart';
import '../../widgets/information_container.dart';
import '../exercise/exercise_type_screen.dart';

class ExerciseEditorScreen extends StatefulWidget {
  final ExerciseDto? exercise;

  const ExerciseEditorScreen({super.key, this.exercise});

  @override
  State<ExerciseEditorScreen> createState() => _ExerciseEditorScreenState();
}

class _ExerciseEditorScreenState extends State<ExerciseEditorScreen> {
  String? _exerciseName;

  late MuscleGroup _primaryMuscleGroup;
  late ExerciseType _exerciseType;

  bool _loading = false;
  String _loadingLabel = "";

  bool _isInputFieldVisible = false;

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;

    final inactiveStyle = GoogleFonts.montserrat(color: Colors.white70, fontSize: 22, fontWeight: FontWeight.w600);
    final activeStyle = GoogleFonts.montserrat(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600);

    return PopScope(
        canPop: false,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              exercise != null
                  ? CTextButton(
                      onPressed: _updateExercise,
                      label: "Update",
                      buttonColor: Colors.transparent,
                      buttonBorderColor: Colors.transparent,
                      loading: _loading,
                      loadingLabel: _loadingLabel)
                  : const SizedBox.shrink()
            ],
          ),
          body: SafeArea(
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
                      icon: FaIcon(FontAwesomeIcons.lightbulb, size: 16),
                      title: 'Tip',
                      description: "Tap text in white to edit.\nExercise type is not editable once created.",
                      color: tealBlueDark),
                  SizedBox(height: 20),
                ]),
              if (!_isInputFieldVisible && _exerciseName != null && exercise == null)
                SizedBox(
                  width: double.infinity,
                  child: CTextButton(
                      onPressed: _createExercise,
                      label: "Create Exercise",
                      loading: _loading,
                      loadingLabel: _loadingLabel,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      buttonColor: Colors.green),
                ),
            ]),
          ),
        ));
  }

  void _toggleLoadingState() {
    setState(() {
      _loading = !_loading;
      _loadingLabel = widget.exercise != null ? "Updating" : "Creating";
    });
  }

  void _navigateToMuscleGroupsScreen() async {
    final muscleGroup = await Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => MuscleGroupsScreen(previousMuscleGroup: _primaryMuscleGroup)))
        as MuscleGroup;
    setState(() {
      _primaryMuscleGroup = muscleGroup;
    });
  }

  void _navigateToExerciseTypeScreen() async {
    if (widget.exercise != null) return;
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
      _exerciseName = capitalizeFirstLetter(value.trim());
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
    await displayBottomSheet(
        context: context,
        color: Colors.transparent,
        padding: const EdgeInsets.all(20),
        child: TextField(
          controller: TextEditingController(text: _exerciseName),
          decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5), borderSide: const BorderSide(color: tealBlueLighter)),
              filled: true,
              fillColor: tealBlueLighter,
              hintText: "New Exercise",
              hintStyle: GoogleFonts.montserrat(color: Colors.grey, fontSize: 14)),
          onChanged: (value) => _updateExerciseName(value),
          cursorColor: Colors.white,
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.words,
          style:
              GoogleFonts.montserrat(fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.8), fontSize: 14),
        ));
    _doneTyping();
  }

  void _createExercise() async {
    final exerciseName = _exerciseName;

    if (exerciseName == null) return;

    if (exerciseName.isEmpty) {
      showSnackbar(
          context: context, icon: const Icon(Icons.info_outline), message: "Please provide a name for this exercise");
    } else {
      _toggleLoadingState();

      final exercise =
          ExerciseDto(id: "", name: exerciseName, primaryMuscleGroup: _primaryMuscleGroup, type: _exerciseType);

      try {
        await Provider.of<ExerciseProvider>(context, listen: false).saveExercise(exerciseDto: exercise);
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          showSnackbar(context: context, icon: const Icon(Icons.info_outline), message: "Unable to create exercise");
        }
      } finally {
        _toggleLoadingState();
      }
    }
  }

  void _updateExercise() async {
    final exerciseName = _exerciseName;

    if (exerciseName == null) return;

    if (exerciseName.isEmpty) {
      showSnackbar(
          context: context, icon: const Icon(Icons.info_outline), message: "Please provide a name for this exercise");
    } else {
      final exercise = widget.exercise;
      if (exercise == null) return;

      _toggleLoadingState();

      try {
        final updatedExercise = exercise.copyWith(
            name: capitalizeFirstLetter(exerciseName.trim()), primaryMuscleGroup: _primaryMuscleGroup);
        await Provider.of<ExerciseProvider>(context, listen: false).updateExercise(exercise: updatedExercise);
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (_) {
        if (mounted) {
          showSnackbar(context: context, icon: const Icon(Icons.info_outline), message: "Unable to update exercise");
        }
      } finally {
        _toggleLoadingState();
      }
    }
  }

  @override
  void initState() {
    super.initState();

    final previousExercise = widget.exercise;

    _primaryMuscleGroup = previousExercise != null
        ? previousExercise.primaryMuscleGroup
        : MuscleGroup.values.sorted((a, b) => a.name.compareTo(b.name)).first;

    _exerciseType = previousExercise != null ? previousExercise.type : ExerciseType.weights;

    _exerciseName = previousExercise?.name;
  }
}

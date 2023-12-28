import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/providers/exercise_provider.dart';
import 'package:tracker_app/screens/exercise/muscle_groups_screen.dart';
import 'package:tracker_app/widgets/helper_widgets/dialog_helper.dart';

import '../../app_constants.dart';
import '../../dtos/exercise_dto.dart';
import '../../enums/exercise_type_enums.dart';
import '../../widgets/buttons/text_button_widget.dart';
import '../exercise/exercise_type_screen.dart';

class ExerciseEditorScreen extends StatefulWidget {
  final ExerciseDto? exercise;

  const ExerciseEditorScreen({super.key, this.exercise});

  @override
  State<ExerciseEditorScreen> createState() => _ExerciseEditorScreenState();
}

class _ExerciseEditorScreenState extends State<ExerciseEditorScreen> {
  late TextEditingController _exerciseNameController;
  late TextEditingController _exerciseNotesController;

  late MuscleGroup _primaryMuscleGroup;
  List<MuscleGroup> _secondaryMuscleGroups = [];
  late ExerciseType _exerciseType;

  bool _loading = false;
  String _loadingLabel = "";

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_outlined),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            exercise != null
                ? CTextButton(
                    onPressed: _updateExercise,
                    label: "Update",
                    buttonColor: Colors.transparent,
                    loading: _loading,
                    loadingLabel: _loadingLabel)
                : const SizedBox.shrink()
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(right: 10.0, bottom: 10, left: 10),
            child: Column(children: [
              TextField(
                controller: _exerciseNameController,
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5), borderSide: const BorderSide(color: tealBlueLighter)),
                    filled: true,
                    fillColor: tealBlueLighter,
                    hintText: "New Exercise",
                    hintStyle: GoogleFonts.lato(color: Colors.grey, fontSize: 14)),
                cursorColor: Colors.white,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.words,
                style:
                    GoogleFonts.lato(fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.8), fontSize: 14),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _exerciseNotesController,
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5), borderSide: const BorderSide(color: tealBlueLighter)),
                    filled: true,
                    fillColor: tealBlueLighter,
                    hintText: "Notes",
                    hintStyle: GoogleFonts.lato(color: Colors.grey, fontSize: 14)),
                maxLines: null,
                cursorColor: Colors.white,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
                style:
                    GoogleFonts.lato(fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.8), fontSize: 14),
              ),
              const SizedBox(height: 10),
              Theme(
                data: ThemeData(splashColor: tealBlueLight),
                child: ListTile(
                    onTap: _navigateToMuscleGroupsScreen,
                    tileColor: tealBlueLight,
                    dense: true,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    title: Text("Primary Muscle", style: GoogleFonts.lato(color: Colors.white, fontSize: 14)),
                    subtitle:
                        Text(_primaryMuscleGroup.name, style: GoogleFonts.lato(fontSize: 13, color: Colors.white70))),
              ),
              const SizedBox(height: 8),
              Theme(
                data: ThemeData(splashColor: tealBlueLight),
                child: ListTile(
                    onTap: () => _navigateToMuscleGroupsScreen(multiSelect: true),
                    tileColor: tealBlueLight,
                    dense: true,
                    contentPadding: _secondaryMuscleGroups.length > 6
                        ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                        : null,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    title: Text("Secondary Muscles", style: GoogleFonts.lato(color: Colors.white, fontSize: 14)),
                    subtitle: Padding(
                      padding: _secondaryMuscleGroups.length > 6 ? const EdgeInsets.only(top: 4.0) : EdgeInsets.zero,
                      child:
                          Text(_secondaryMuscleDisplay(), style: GoogleFonts.lato(fontSize: 13, color: Colors.white70)),
                    )),
              ),
              const SizedBox(height: 8),
              if (widget.exercise == null)
                Column(children: [
                  Theme(
                    data: ThemeData(splashColor: tealBlueLight),
                    child: ListTile(
                        onTap: () => _navigateToExerciseTypeScreen(),
                        tileColor: tealBlueLight,
                        dense: true,
                        contentPadding: _secondaryMuscleGroups.length > 6
                            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                            : null,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        title: Text("Exercise Type", style: GoogleFonts.lato(color: Colors.white, fontSize: 14)),
                        subtitle:
                            Text(_exerciseType.name, style: GoogleFonts.lato(fontSize: 13, color: Colors.white70))),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: CTextButton(
                        onPressed: _createExercise,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        label: "Create exercise",
                        loading: _loading,
                        loadingLabel: _loadingLabel),
                  )
                ])
            ]),
          ),
        ),
      ),
    );
  }

  String _secondaryMuscleDisplay() {
    String display;
    if (_secondaryMuscleGroups.isNotEmpty) {
      display = _secondaryMuscleGroups.map((bodyPart) => bodyPart.name).join(", ");
    } else {
      display = "Select secondary muscle groups";
    }
    return display;
  }

  void _toggleLoadingState() {
    setState(() {
      _loading = !_loading;
      _loadingLabel = widget.exercise != null ? "Updating" : "Creating";
    });
  }

  void _navigateToMuscleGroupsScreen({bool multiSelect = false}) async {
    final exercise = widget.exercise;
    List<MuscleGroup> preSelectedMuscleGroups = multiSelect ? _secondaryMuscleGroups : [_primaryMuscleGroup];
    if (exercise != null) {
      preSelectedMuscleGroups = multiSelect ? _secondaryMuscleGroups : [_primaryMuscleGroup];
    }

    final muscleGroups = await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => MuscleGroupsScreen(muscleGroups: preSelectedMuscleGroups, multiSelect: multiSelect)))
        as List<MuscleGroup>?;
    if (muscleGroups != null) {
      if (multiSelect) {
        setState(() {
          _secondaryMuscleGroups = muscleGroups;
        });
      } else {
        setState(() {
          _primaryMuscleGroup = muscleGroups.first;
        });
      }
    }
  }

  void _navigateToExerciseTypeScreen() async {
    final type = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ExerciseTypeScreen()))
        as ExerciseType?;
    if (type != null) {
      setState(() {
        _exerciseType = type;
      });
    }
  }

  void _createExercise() async {
    _toggleLoadingState();

    final exercise = ExerciseDto(
        id: "",
        name: _exerciseNameController.text.trim(),
        notes: _exerciseNotesController.text.trim(),
        primaryMuscleGroup: _primaryMuscleGroup,
        secondaryMuscleGroups: _secondaryMuscleGroups,
        type: _exerciseType,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now());

    try {
      await Provider.of<ExerciseProvider>(context, listen: false).saveExercise(exerciseDto: exercise);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        showSnackbar(context: context, icon: const Icon(Icons.info_outline), message: "Unable to create exercise");
      }
    } finally {
      _toggleLoadingState();
    }
  }

  void _updateExercise() async {
    if (_exerciseNameController.text.isEmpty) {
      showSnackbar(
          context: context, icon: const Icon(Icons.info_outline), message: "Please provide a name for this exercise");
    } else {
      final exercise = widget.exercise;
      if (exercise != null) {
        _toggleLoadingState();
        try {
          final updatedExercise = exercise.copyWith(
              name: _exerciseNameController.text.trim(),
              notes: _exerciseNotesController.text.trim(),
              primaryMuscleGroup: _primaryMuscleGroup,
              secondaryMuscleGroups: _secondaryMuscleGroups);
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
  }

  @override
  void initState() {
    super.initState();

    final previousExercise = widget.exercise;

    _exerciseNameController = TextEditingController(text: previousExercise?.name);
    _exerciseNotesController = TextEditingController(text: previousExercise?.notes);

    _primaryMuscleGroup = previousExercise != null ? previousExercise.primaryMuscleGroup : MuscleGroup.values.first;
    _secondaryMuscleGroups = previousExercise?.secondaryMuscleGroups ?? [];
    _exerciseType = previousExercise != null ? previousExercise.type : ExerciseType.weightAndReps;
  }

  @override
  void dispose() {
    super.dispose();
    _exerciseNameController.dispose();
    _exerciseNotesController.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/providers/exercise_provider.dart';
import 'package:tracker_app/screens/exercise/muscle_groups_screen.dart';

import '../../app_constants.dart';
import '../../models/Exercise.dart';
import '../../widgets/buttons/text_button_widget.dart';

class ExerciseEditorScreen extends StatefulWidget {

  final Exercise? exercise;
  const ExerciseEditorScreen({super.key, this.exercise});

  @override
  State<ExerciseEditorScreen> createState() => _ExerciseEditorScreenState();
}

class _ExerciseEditorScreenState extends State<ExerciseEditorScreen> {

  late TextEditingController _exerciseNameController;
  late TextEditingController _exerciseNotesController;

  late MuscleGroup _primaryMuscleGroup;
  List<MuscleGroup> _secondaryMuscleGroup = [];

  @override
  Widget build(BuildContext context) {

    final exercise = widget.exercise;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [exercise != null ? CTextButton(onPressed: () {}, label: "Update", buttonColor: Colors.transparent) : const SizedBox.shrink()],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(children: [
            TextField(
              controller: _exerciseNameController,
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2),
                      borderSide: const BorderSide(color: tealBlueLighter)),
                  filled: true,
                  fillColor: tealBlueLighter,
                  hintText: "New Exercise",
                  hintStyle: GoogleFonts.lato(color: Colors.grey, fontSize: 14)),
              cursorColor: Colors.white,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.words,
              style: GoogleFonts.lato(
                  fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.8), fontSize: 14),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _exerciseNotesController,
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2),
                      borderSide: const BorderSide(color: tealBlueLighter)),
                  filled: true,
                  fillColor: tealBlueLighter,
                  hintText: "Notes",
                  hintStyle: GoogleFonts.lato(color: Colors.grey, fontSize: 14)),
              maxLines: null,
              cursorColor: Colors.white,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.sentences,
              style: GoogleFonts.lato(
                  fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.8), fontSize: 14),
            ),
            const SizedBox(height: 10),
            Theme(
              data: ThemeData(splashColor: tealBlueLight),
              child: ListTile(
                  onTap: _navigateToMuscleGroupsScreen,
                  tileColor: tealBlueLight,
                  dense: true,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                  title: Text("Primary Muscle", style: Theme.of(context).textTheme.labelLarge),
                  subtitle: Text(_primaryMuscleGroup.name,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white70))),
            ),
            const SizedBox(height: 8),
            Theme(
              data: ThemeData(splashColor: tealBlueLight),
              child: ListTile(
                  onTap: () => _navigateToMuscleGroupsScreen(multiSelect: true),
                  tileColor: tealBlueLight,
                  dense: true,
                  contentPadding: _secondaryMuscleGroup.length > 6 ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12) : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                  title: Text("Secondary Muscles", style: Theme.of(context).textTheme.labelLarge),
                  subtitle: Padding(
                    padding: _secondaryMuscleGroup.length > 6 ? const EdgeInsets.only(top: 4.0) : EdgeInsets.zero,
                    child: Text(_secondaryMuscleGroup.map((bodyPart) => bodyPart.name).join(", "),
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white70)),
                  )),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: CTextButton(onPressed: _createExercise, label: "Create exercise"),
            )
          ]),
        ),
      ),
    );
  }

  void _navigateToMuscleGroupsScreen({bool multiSelect = false}) async {
    final muscleGroups = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => MuscleGroupsScreen(multiSelect: multiSelect))) as List<MuscleGroup>?;
    if(muscleGroups != null) {
      if(multiSelect) {
        setState(() {
          _secondaryMuscleGroup = muscleGroups;
        });
      } else {
        setState(() {
          _primaryMuscleGroup = muscleGroups.first;
        });
      }
    }
  }

  void _createExercise() async {
    await Provider.of<ExerciseProvider>(context, listen: false)
        .saveExercise(name: _exerciseNameController.text, notes: _exerciseNotesController.text, primary: _primaryMuscleGroup, secondary: _secondaryMuscleGroup);
    if(mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    final exercise = widget.exercise;
    _exerciseNameController = TextEditingController(text: exercise?.name);
    _exerciseNotesController = TextEditingController(text: exercise?.notes);

    _primaryMuscleGroup = MuscleGroup.values.first;
  }

    @override
  void dispose() {
    super.dispose();
      _exerciseNameController.dispose();
      _exerciseNotesController.dispose();
  }
}

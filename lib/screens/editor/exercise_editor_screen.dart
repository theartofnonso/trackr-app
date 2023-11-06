import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/models/BodyPart.dart';
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

  late BodyPart _primaryBodyPart;
  late List<BodyPart> _secondaryBodyPart;

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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                  title: Text("Primary Muscle", style: Theme.of(context).textTheme.labelLarge),
                  subtitle: Text(_primaryBodyPart.name,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white70))),
            ),
            const SizedBox(height: 6),
            Theme(
              data: ThemeData(splashColor: tealBlueLight),
              child: ListTile(
                  onTap: () => _navigateToMuscleGroupsScreen(multiSelect: true),
                  tileColor: tealBlueLight,
                  contentPadding: _secondaryBodyPart.length > 6 ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12) : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                  title: Text("Secondary Muscles", style: Theme.of(context).textTheme.labelLarge),
                  subtitle: Padding(
                    padding: _secondaryBodyPart.length > 6 ? const EdgeInsets.only(top: 4.0) : EdgeInsets.zero,
                    child: Text(_secondaryBodyPart.map((bodyPart) => bodyPart.name).join(", "),
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white70)),
                  )),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: CTextButton(onPressed: () {}, label: "Create exercise"),
            )
          ]),
        ),
      ),
    );
  }

  void _navigateToMuscleGroupsScreen({bool multiSelect = false}) async {
    final muscleGroups = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => MuscleGroupsScreen(multiSelect: multiSelect))) as List<MuscleGroupDto>;
    if(multiSelect) {

    }
  }

  @override
  void initState() {
    super.initState();
    final exercise = widget.exercise;
    _exerciseNameController = TextEditingController(text: exercise?.name);
    _exerciseNotesController = TextEditingController(text: exercise?.notes);

    _primaryBodyPart = BodyPart.values.first;
    _secondaryBodyPart = BodyPart.values.take(4).toList();
  }

    @override
  void dispose() {
    super.dispose();
      _exerciseNameController.dispose();
      _exerciseNotesController.dispose();
  }
}

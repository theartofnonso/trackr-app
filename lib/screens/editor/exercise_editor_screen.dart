import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app_constants.dart';
import '../../models/Exercise.dart';

class ExerciseEditorScreen extends StatefulWidget {

  final Exercise? exercise;
  const ExerciseEditorScreen({super.key, this.exercise});

  @override
  State<ExerciseEditorScreen> createState() => _ExerciseEditorScreenState();
}

class _ExerciseEditorScreenState extends State<ExerciseEditorScreen> {

  late TextEditingController _exerciseNameController;
  late TextEditingController _exerciseNotesController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
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
        ]),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final exercise = widget.exercise;
    _exerciseNameController = TextEditingController(text: exercise?.name);
    _exerciseNotesController = TextEditingController(text: exercise?.notes);
  }

    @override
  void dispose() {
    super.dispose();
      _exerciseNameController.dispose();
      _exerciseNotesController.dispose();
  }
}

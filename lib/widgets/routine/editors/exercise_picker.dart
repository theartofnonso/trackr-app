import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app_constants.dart';
import '../../../dtos/exercise_log_dto.dart';
import '../../buttons/text_button_widget.dart';
import '../../empty_states/list_tile_empty_state.dart';

class ExercisePicker extends StatelessWidget {
  final ExerciseLogDto selectedExercise;
  final List<ExerciseLogDto> exercises;
  final void Function(ExerciseLogDto procedure) onSelect;
  final void Function() onSelectExercisesInLibrary;

  const ExercisePicker({super.key, required this.selectedExercise, required this.exercises, required this.onSelect, required this.onSelectExercisesInLibrary});

  @override
  Widget build(BuildContext context) {
    final listTiles = exercises
        .map((procedure) => ListTile(
        onTap: () => onSelect(procedure),
        dense: true,
        title: Text(procedure.exercise.name, style: GoogleFonts.lato(color: Colors.white))))
        .toList();

    return exercises.isNotEmpty
        ? SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, top: 10.0),
            child: Text("Superset ${selectedExercise.exercise.name} with", style: GoogleFonts.lato(color: Colors.white70, fontWeight: FontWeight.w500)),
          ),
          ...listTiles],
      ),
    )
        : _ProceduresPickerEmptyState(onPressed: onSelectExercisesInLibrary);
  }
}

class _ProceduresPickerEmptyState extends StatelessWidget {
  final VoidCallback onPressed;

  const _ProceduresPickerEmptyState({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 18.0),
            child: ListTileEmptyState(),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.only(left: 18.0),
            child: ListTileEmptyState(),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SizedBox(
              width: double.infinity,
              child: CTextButton(onPressed: onPressed, label: "Add more exercises", buttonColor: tealBlueLighter),
            ),
          )
        ],
      ),
    );
  }
}
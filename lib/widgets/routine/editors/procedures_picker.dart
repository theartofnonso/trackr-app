import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app_constants.dart';
import '../../../dtos/exercise_log_dto.dart';
import '../../buttons/text_button_widget.dart';
import '../../empty_states/list_tile_empty_state.dart';

class ProceduresPicker extends StatelessWidget {
  final List<ExerciseLogDto> procedures;
  final void Function(ExerciseLogDto procedure) onSelect;
  final void Function() onSelectExercisesInLibrary;

  const ProceduresPicker({super.key, required this.procedures, required this.onSelect, required this.onSelectExercisesInLibrary});

  @override
  Widget build(BuildContext context) {
    final listTiles = procedures
        .map((procedure) => ListTile(
        onTap: () => onSelect(procedure),
        dense: true,
        title: Text(procedure.exercise.name, style: GoogleFonts.lato(color: Colors.white))))
        .toList();

    return procedures.isNotEmpty
        ? SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [...listTiles],
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
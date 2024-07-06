import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/colors.dart';

import '../../../../dtos/exercise_dto.dart';
import '../../../buttons/text_button_widget.dart';
import '../../../empty_states/list_tile_empty_state.dart';

class SubstituteExercisePicker extends StatelessWidget {
  final String title;
  final List<ExerciseDto> exercises;
  final void Function(ExerciseDto exericse) onSelect;
  final void Function(ExerciseDto exericse) onRemove;
  final void Function() onSelectExercisesInLibrary;

  const SubstituteExercisePicker(
      {super.key,
      required this.title,
      required this.exercises,
      required this.onSelect,
      required this.onRemove,
      required this.onSelectExercisesInLibrary});

  @override
  Widget build(BuildContext context) {
    final listTiles = exercises
        .map((exercise) => Dismissible(
              direction: DismissDirection.endToStart,
              onDismissed: (_) {
                onRemove(exercise);
              },
              key: ValueKey(exercise.id),
              child: ListTile(
                onTap: () {
                  onSelect(exercise);
                },
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(exercise.name,
                    style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15)),
              ),
            ))
        .toList();

    return exercises.isNotEmpty
        ? SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 10),
                  child: Text(title,
                      textAlign: TextAlign.start,
                      style: GoogleFonts.montserrat(color: Colors.white70, fontWeight: FontWeight.w500, fontSize: 15)),
                ),
                ...listTiles,
                const SizedBox(height: 12),
                Center(
                  child: CTextButton(
                      onPressed: onSelectExercisesInLibrary,
                      label: "Add substitute exercises",
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
                      buttonColor: vibrantGreen),
                )
              ],
            ),
          )
        : _EmptyState(onPressed: onSelectExercisesInLibrary);
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onPressed;

  const _EmptyState({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.only(left: 18.0),
            child: ListTileEmptyState(),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.only(left: 18.0),
            child: ListTileEmptyState(),
          ),
          const SizedBox(height: 24),
          CTextButton(
              onPressed: onPressed,
              label: "Add substitute exercises",
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
              buttonColor: vibrantGreen)
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../colors.dart';
import '../../../../dtos/exercise_log_dto.dart';
import '../../../buttons/opacity_button_widget.dart';
import '../../../empty_states/list_tile_empty_state.dart';

class SuperSetExerciseLogPicker extends StatelessWidget {
  final String title;
  final List<ExerciseLogDto> exercises;
  final void Function(ExerciseLogDto exericseLog) onSelect;
  final void Function() onSelectExercisesInLibrary;

  const SuperSetExerciseLogPicker(
      {super.key,
      required this.title,
      required this.exercises,
      required this.onSelect,
      required this.onSelectExercisesInLibrary});

  @override
  Widget build(BuildContext context) {
    final listTiles = exercises
        .map((exercise) => ListTile(
              onTap: () {
                onSelect(exercise);
              },
              dense: true,
      contentPadding: EdgeInsets.zero,
              title: Text(exercise.exercise.name,
                  style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15)),
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
                      style: GoogleFonts.ubuntu(color: Colors.white70, fontWeight: FontWeight.w500, fontSize: 15)),
                ),
                ...listTiles
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
          OpacityButtonWidget(
              onPressed: onPressed,
              label: "Add more exercises",
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              buttonColor: vibrantGreen)
        ],
      ),
    );
  }
}

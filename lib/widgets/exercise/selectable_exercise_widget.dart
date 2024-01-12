import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/app_constants.dart';

import '../../screens/exercise/exercise_library_screen.dart';

class SelectableExerciseWidget extends StatelessWidget {
  final ExerciseInLibraryDto exerciseInLibraryDto;
  final void Function(bool selected) onTap;
  final void Function() onNavigateToExercise;

  const SelectableExerciseWidget(
      {super.key, required this.exerciseInLibraryDto, required this.onTap, required this.onNavigateToExercise});

  void _onTap() {
    final isSelected = !exerciseInLibraryDto.selected;
    onTap(isSelected);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
      ),
      child: ListTile(
        onTap: _onTap,
        hoverColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        dense: true,
        title: Text(exerciseInLibraryDto.exercise.name,
            style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        subtitle: Text(
          "Primary: ${exerciseInLibraryDto.exercise.primaryMuscleGroup.name}",
          style: GoogleFonts.montserrat(color: Colors.white70, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          iconSize: 24,
          onPressed: onNavigateToExercise,
          icon: const Icon(
            Icons.timeline_rounded,
            color: Colors.white,
          ),
        ),
        trailing: Row(children: [
          if (exerciseInLibraryDto.exercise.owner)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: tealBlueLighter,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                "user",
                style: GoogleFonts.montserrat(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          exerciseInLibraryDto.selected
              ? const Icon(Icons.check_box_rounded, color: Colors.green)
              : const Icon(Icons.check_box_rounded, color: tealBlueLighter)
        ]),
      ),
    );
  }
}

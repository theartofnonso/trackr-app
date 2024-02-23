import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/colors.dart';

import '../../screens/exercise/exercise_library_screen.dart';

class SelectableExerciseWidget extends StatelessWidget {
  final ExerciseInLibraryDto exerciseInLibraryDto;
  final void Function(ExerciseInLibraryDto exerciseInLibraryDto, bool selected)? onSelect;
  final void Function(ExerciseInLibraryDto exerciseInLibraryDto)? onNavigateToExercise;

  const SelectableExerciseWidget(
      {super.key, required this.exerciseInLibraryDto, required this.onSelect, required this.onNavigateToExercise});

  void _onTap() {
    final selectExercise = onSelect;
    if (selectExercise != null) {
      selectExercise(exerciseInLibraryDto, !exerciseInLibraryDto.selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final navigateToExercise = onNavigateToExercise;

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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Primary: ${exerciseInLibraryDto.exercise.primaryMuscleGroup.name}",
              style: GoogleFonts.montserrat(color: Colors.white70, fontWeight: FontWeight.w500),
            ),
            if (exerciseInLibraryDto.exercise.owner)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: sapphireLighter,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  "owner",
                  style: GoogleFonts.montserrat(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
          ],
        ),
        leading: IconButton(
          iconSize: 24,
          onPressed: () => navigateToExercise != null ? navigateToExercise(exerciseInLibraryDto) : null,
          icon: const Icon(
            Icons.timeline_rounded,
            color: Colors.white,
          ),
        ),
        horizontalTitleGap: 10,
        trailing: exerciseInLibraryDto.selected
            ? const FaIcon(FontAwesomeIcons.solidSquareCheck, color: vibrantGreen)
            : const FaIcon(FontAwesomeIcons.solidSquareCheck, color: sapphireDark),
      ),
    );
  }
}

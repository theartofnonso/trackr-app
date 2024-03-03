import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/colors.dart';

import '../../screens/exercise/library/exercise_library_screen.dart';

class ExerciseWidget extends StatelessWidget {
  final ExerciseInLibraryDto exerciseInLibraryDto;
  final void Function(ExerciseInLibraryDto exerciseInLibraryDto)? onSelect;
  final void Function(ExerciseInLibraryDto exerciseInLibraryDto)? onNavigateToExercise;

  const ExerciseWidget(
      {super.key, required this.exerciseInLibraryDto, required this.onSelect, required this.onNavigateToExercise});

  @override
  Widget build(BuildContext context) {
    final selectExercise = onSelect;
    final navigateToExercise = onNavigateToExercise;

    return Theme(
        data: ThemeData(splashColor: sapphireLight),
        child: ListTile(
            leading: IconButton(
              iconSize: 24,
              onPressed: () => navigateToExercise != null ? navigateToExercise(exerciseInLibraryDto) : null,
              icon: const Icon(
                Icons.timeline_rounded,
                color: Colors.white,
              ),
            ),
            contentPadding: EdgeInsets.zero,
            horizontalTitleGap: 10,
            title: Text(exerciseInLibraryDto.exercise.name,
                style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
            onTap: () => selectExercise != null ? selectExercise(exerciseInLibraryDto) : null,
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
            )));
  }
}

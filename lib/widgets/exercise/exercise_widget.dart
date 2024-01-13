import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/app_constants.dart';

import '../../screens/exercise/exercise_library_screen.dart';

class ExerciseWidget extends StatelessWidget {
  final ExerciseInLibraryDto exerciseInLibraryDto;
  final void Function() onTap;
  final void Function() onNavigateToExercise;

  const ExerciseWidget(
      {super.key, required this.exerciseInLibraryDto, required this.onTap, required this.onNavigateToExercise});

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData(splashColor: tealBlueLight),
        child: ListTile(
          leading: IconButton(
            iconSize: 24,
            onPressed: onNavigateToExercise,
            icon: const Icon(
              Icons.timeline_rounded,
              color: Colors.white,
            ),
          ),
          horizontalTitleGap: 4,
          title: Text(exerciseInLibraryDto.exercise.name,
              style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
          onTap: onTap,
          subtitle: Text(
            "Primary: ${exerciseInLibraryDto.exercise.primaryMuscleGroup.name}",
            style: GoogleFonts.montserrat(color: Colors.white70, fontWeight: FontWeight.w500),
          ),
          trailing: exerciseInLibraryDto.exercise.owner ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: tealBlueLighter,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text("owner",
              style: GoogleFonts.montserrat(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ) : null,
        ));
  }
}

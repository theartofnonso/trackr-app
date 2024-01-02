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

    final secondaryMuscleGroups = exerciseInLibraryDto.exercise.secondaryMuscleGroups.isNotEmpty
        ? exerciseInLibraryDto.exercise.secondaryMuscleGroups.map((muscleGroup) => muscleGroup.name).join(", ")
        : "None";

    return Theme(
      data: ThemeData(splashColor: tealBlueLight),
      child: ListTile(
          leading: IconButton(
            onPressed: onNavigateToExercise,
            icon: const Icon(
              Icons.timeline_rounded,
              color: Colors.white,
            ),
          ),
          title: Text(exerciseInLibraryDto.exercise.name, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14)),
          onTap: onTap,
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  width: 300,
                  child: Text(
                    "Primary: ${exerciseInLibraryDto.exercise.primaryMuscleGroup.name}",
                    style: GoogleFonts.montserrat(color: Colors.white70).copyWith(overflow: TextOverflow.ellipsis),
                  )),
              SizedBox(
                  width: 300,
                  child: Text(
                    "Secondary: $secondaryMuscleGroups",
                    style: GoogleFonts.montserrat(color: Colors.white70).copyWith(overflow: TextOverflow.ellipsis),
                  )),
            ],
          )),
    );
  }
}

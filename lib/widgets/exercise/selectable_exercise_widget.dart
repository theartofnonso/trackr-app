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

    final secondaryMuscleGroups = exerciseInLibraryDto.exercise.secondaryMuscleGroups.isNotEmpty
        ? exerciseInLibraryDto.exercise.secondaryMuscleGroups.map((muscleGroup) => muscleGroup.name).join(", ")
        : "None";

    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
      ),
      child: ListTile(
        onTap: _onTap,
        hoverColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        dense: true,
        title: Text(exerciseInLibraryDto.exercise.name, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14)),
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
        ),
        leading: IconButton(
          onPressed: onNavigateToExercise,
          icon: const Icon(
            Icons.timeline_rounded,
            color: Colors.white,
          ),
        ),
        trailing: exerciseInLibraryDto.selected
            ? const Icon(Icons.check_box_rounded, color: Colors.green)
            : const Icon(Icons.check_box_rounded, color: tealBlueLighter),
      ),
    );
  }
}

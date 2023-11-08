import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../screens/exercise/exercise_library_screen.dart';

class SelectableExerciseWidget extends StatelessWidget {
  final ExerciseInLibraryDto exerciseInLibraryDto;
  final void Function(bool selected) onTap;
  final void Function() onNavigateToExercise;

  const SelectableExerciseWidget({super.key, required this.exerciseInLibraryDto, required this.onTap, required this.onNavigateToExercise});

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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 300,
                child: Text(
                  "Primary: ${exerciseInLibraryDto.exercise.primaryMuscle}",
                  style: GoogleFonts.lato(
                      color: Colors.white70).copyWith(overflow: TextOverflow.ellipsis),
                )),
            SizedBox(
                width: 300,
                child: Text(
                  "Secondary: ${exerciseInLibraryDto.exercise.secondaryMuscles.isNotEmpty ? exerciseInLibraryDto.exercise.secondaryMuscles.join(", ") : "None"}",
                  style: GoogleFonts.lato(
                      color: Colors.white70).copyWith(overflow: TextOverflow.ellipsis),
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
        trailing: exerciseInLibraryDto.selected ? const Icon(Icons.check_box_rounded, color: Colors.green) : Icon(Icons.check_box_rounded, color: Colors.grey.shade800),
      ),
    );
  }
}

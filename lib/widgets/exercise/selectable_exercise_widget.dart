import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../screens/exercise/exercise_history_screen.dart';
import '../../screens/exercise/exercise_library_screen.dart';

class SelectableExerciseWidget extends StatelessWidget {
  final ExerciseInLibraryDto exerciseInLibraryDto;
  final void Function(bool selected) onTap;

  const SelectableExerciseWidget({super.key, required this.exerciseInLibraryDto, required this.onTap});

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
      child: CheckboxListTile(
        value: exerciseInLibraryDto.selected,
        onChanged: (bool? _) => _onTap(),
        activeColor: Colors.white,
        checkColor: Colors.black,
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
                  "Primary: ${exerciseInLibraryDto.exercise.primaryMuscle.name}",
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
        secondary: IconButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ExerciseHistoryScreen(exerciseId: exerciseInLibraryDto.exercise.id)));
          },
          icon: const Icon(
            Icons.timeline_rounded,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

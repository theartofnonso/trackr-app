import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../dtos/exercise_dto.dart';

class ExerciseWidget extends StatelessWidget {
  final ExerciseDto exerciseDto;
  final void Function(ExerciseDto exerciseInLibraryDto)? onSelect;
  final void Function(ExerciseDto exerciseInLibraryDto)? onNavigateToExercise;

  const ExerciseWidget(
      {super.key, required this.exerciseDto, required this.onSelect, required this.onNavigateToExercise});

  @override
  Widget build(BuildContext context) {
    final selectExercise = onSelect;
    final navigateToExercise = onNavigateToExercise;

    final exercise = exerciseDto;
    final description = exerciseDto.description ?? "";

    return GestureDetector(
      onTap: () => selectExercise != null ? selectExercise(exerciseDto) : null,
      child: Container(
        color: Colors.transparent,
        width: double.infinity,
        padding: const EdgeInsets.only(left: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(exercise.name,
                style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18)),
            if (description.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Text(description,
                      style: GoogleFonts.montserrat(
                          color: Colors.white70, height: 1.8, fontWeight: FontWeight.w400, fontSize: 14)),
                ],
              ),
            const SizedBox(
              height: 6,
            ),
            Row(
              children: [
                Text(exercise.primaryMuscleGroup.name.toUpperCase(),
                    style: GoogleFonts.montserrat(color: Colors.orange, fontWeight: FontWeight.w600, fontSize: 12)),
                const Spacer(),
                if (exercise.owner)
                  Text("Owner".toUpperCase(),
                      style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

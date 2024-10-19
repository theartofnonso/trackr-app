import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exercise.name,
                      style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18)),
                  if (description.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Text(description,
                            style: GoogleFonts.ubuntu(
                                color: Colors.white70, height: 1.8, fontWeight: FontWeight.w400, fontSize: 14)),
                      ],
                    ),
                  const SizedBox(
                    height: 6,
                  ),
                  RichText(
                      text: TextSpan(
                          text: exercise.primaryMuscleGroup.name.toUpperCase(),
                          style: GoogleFonts.ubuntu(
                              color: Colors.deepOrangeAccent, fontWeight: FontWeight.w600, fontSize: 12, height: 1.5),
                          children: [
                        if (exercise.secondaryMuscleGroups.isNotEmpty)
                          [exercise.primaryMuscleGroup, ...exercise.secondaryMuscleGroups].length == 2 ? const TextSpan(text: " & ") : const TextSpan(text: " | "),
                          TextSpan(
                              text: exercise.secondaryMuscleGroups
                                  .map((muscleGroup) => muscleGroup.name.toUpperCase())
                                  .join(", "),
                              style: GoogleFonts.ubuntu(
                                  color: Colors.orange.withOpacity(0.6), fontWeight: FontWeight.w500, fontSize: 11)),
                      ])),
                  if (exercise.owner)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text("Owner".toUpperCase(),
                          style: GoogleFonts.ubuntu(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 8)),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: GestureDetector(
                  onTap: () => navigateToExercise != null ? navigateToExercise(exerciseDto) : null,
                  child: const FaIcon(
                    FontAwesomeIcons.circleArrowRight,
                    color: Colors.white70,
                  )),
            )
          ],
        ),
      ),
    );
  }
}

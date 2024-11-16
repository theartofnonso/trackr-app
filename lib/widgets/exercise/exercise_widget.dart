import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/extensions/muscle_group_extension.dart';

import '../../dtos/exercise_dto.dart';
import '../../utils/string_utils.dart';

class ExerciseWidget extends StatelessWidget {
  final ExerciseDTO exerciseDto;
  final void Function(ExerciseDTO exerciseInLibraryDto)? onSelect;
  final void Function(ExerciseDTO exerciseInLibraryDto)? onNavigateToExercise;

  const ExerciseWidget(
      {super.key, required this.exerciseDto, required this.onSelect, required this.onNavigateToExercise});

  @override
  Widget build(BuildContext context) {
    final selectExercise = onSelect;
    final navigateToExercise = onNavigateToExercise;

    final exercise = exerciseDto;
    final description = exerciseDto.description;

    final primaryMuscleGroupNames = exercise.primaryMuscleGroups.map((muscleGroup) => muscleGroup.name.toUpperCase()).toList();

    final secondaryMuscleGroupNames = exercise.secondaryMuscleGroups.map((muscleGroup) => muscleGroup.name.toUpperCase()).toList();

    return GestureDetector(
      onTap: () => selectExercise != null ? selectExercise(exerciseDto) : null,
      child: Container(
        color: Colors.transparent,
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: SizedBox(
                width: 35,
                height: 35, // Adjust the height as needed
                child: Image.asset(
                  'muscles_illustration/${exercise.primaryMuscleGroups.first.illustration()}.png',
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.low,
                ),
              ),
            ),
            const SizedBox(width: 14),
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
                          text: listWithAnd(strings: primaryMuscleGroupNames),
                          style: GoogleFonts.ubuntu(
                              color: Colors.deepOrangeAccent, fontWeight: FontWeight.w600, fontSize: 12, height: 1.5),
                          children: [
                        if (exercise.secondaryMuscleGroups.isNotEmpty)
                          [...exercise.primaryMuscleGroups, ...exercise.secondaryMuscleGroups].length == 2
                              ? const TextSpan(text: " & ")
                              : const TextSpan(text: " | "),
                        TextSpan(
                            text: listWithAnd(strings: secondaryMuscleGroupNames),
                            style: GoogleFonts.ubuntu(
                                color: Colors.orange.withOpacity(0.6), fontWeight: FontWeight.w500, fontSize: 11)),
                      ])),
                ],
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
                onTap: () => navigateToExercise != null ? navigateToExercise(exerciseDto) : null,
                child: const FaIcon(
                  FontAwesomeIcons.circleInfo,
                  color: Colors.white70,
                ))
          ],
        ),
      ),
    );
  }
}

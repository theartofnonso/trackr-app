import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/extensions/muscle_group_extension.dart';

import '../../dtos/appsync/exercise_dto.dart';
import '../../shared_prefs.dart';

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
    final owner = exercise.owner;

    return GestureDetector(
      onTap: () => selectExercise != null ? selectExercise(exerciseDto) : null,
      child: Container(
        color: Colors.transparent,
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 30,
              height: 30, // Adjust the height as needed
              child: Image.asset(
                'muscles_illustration/${exercise.primaryMuscleGroup.illustration()}.png',
                fit: BoxFit.cover,
                filterQuality: FilterQuality.low,
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
                          text: exercise.primaryMuscleGroup.name.toUpperCase(),
                          style: GoogleFonts.ubuntu(
                              color: Colors.deepOrangeAccent, fontWeight: FontWeight.w600, fontSize: 12, height: 1.5),
                          children: [
                        if (exercise.secondaryMuscleGroups.isNotEmpty)
                          [exercise.primaryMuscleGroup, ...exercise.secondaryMuscleGroups].length == 2
                              ? const TextSpan(text: " & ")
                              : const TextSpan(text: " | "),
                        TextSpan(
                            text: exercise.secondaryMuscleGroups
                                .map((muscleGroup) => muscleGroup.name.toUpperCase())
                                .join(", "),
                            style: GoogleFonts.ubuntu(
                                color: Colors.orange.withOpacity(0.6), fontWeight: FontWeight.w500, fontSize: 11)),
                      ])),
                  if (owner == SharedPrefs().userId)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text("Owner".toUpperCase(),
                          style: GoogleFonts.ubuntu(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 8)),
                    ),
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

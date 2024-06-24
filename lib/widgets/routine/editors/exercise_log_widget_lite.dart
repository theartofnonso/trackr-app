import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';

import '../../../colors.dart';
import '../../../enums/routine_editor_type_enums.dart';

class ExerciseLogLiteWidget extends StatelessWidget {
  final RoutineEditorMode editorType;

  final ExerciseLogDto exerciseLogDto;
  final ExerciseLogDto? superSet;
  final VoidCallback onMaximise;

  const ExerciseLogLiteWidget(
      {super.key, this.editorType = RoutineEditorMode.edit, required this.exerciseLogDto, this.superSet, required this.onMaximise});

  @override
  Widget build(BuildContext context) {
    final sets = exerciseLogDto.sets;

    final superSetExerciseDto = superSet;

    final completedSets = sets.where((set) => set.checked).length;

    final isExerciseCompleted = completedSets == sets.length;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isExerciseCompleted ? vibrantGreen : sapphireDark80, // Set the background color
        borderRadius: BorderRadius.circular(5), // Set the border radius to make it rounded
      ),
      child: GestureDetector(
        onDoubleTap: onMaximise,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exerciseLogDto.exercise.name,
                      style: GoogleFonts.montserrat(
                          color: isExerciseCompleted ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  if (superSetExerciseDto != null)
                    Column(children: [
                      //const SizedBox(height: ,),
                      Text("with ${superSetExerciseDto.exercise.name}",
                          style: GoogleFonts.montserrat(color: isExerciseCompleted ? sapphireDark80 : vibrantGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                    ])
                ],
              ),
              const Spacer(),
              Text("$completedSets/${sets.length}",
                  style: GoogleFonts.montserrat(
                      color: isExerciseCompleted ? Colors.black : Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18)),
            ]),
          ],
        ),
      ),
    );
  }
}

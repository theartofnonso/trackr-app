import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';

import '../../../colors.dart';
import '../../../enums/routine_editor_type_enums.dart';

class ExerciseLogLiteWidget extends StatefulWidget {
  final RoutineEditorMode editorType;

  final ExerciseLogDto exerciseLogDto;
  final ExerciseLogDto? superSet;

  const ExerciseLogLiteWidget(
      {super.key, this.editorType = RoutineEditorMode.edit, required this.exerciseLogDto, this.superSet});

  @override
  State<ExerciseLogLiteWidget> createState() => _ExerciseLogLiteWidgetState();
}

class _ExerciseLogLiteWidgetState extends State<ExerciseLogLiteWidget> {
  @override
  Widget build(BuildContext context) {
    final sets = widget.exerciseLogDto.sets;

    final superSetExerciseDto = widget.superSet;

    final completedSets = sets.where((set) => set.checked).length;

    final isExerciseCompleted = completedSets == sets.length;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isExerciseCompleted ? vibrantGreen : sapphireDark80, // Set the background color
        borderRadius: BorderRadius.circular(5), // Set the border radius to make it rounded
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            FaIcon(FontAwesomeIcons.circleArrowUp, color: isExerciseCompleted ? Colors.black : Colors.white, size: 20,),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.exerciseLogDto.exercise.name,
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
    );
  }
}

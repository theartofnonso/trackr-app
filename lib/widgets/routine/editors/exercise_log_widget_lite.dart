import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';

import '../../../colors.dart';
import '../../../controllers/exercise_and_routine_controller.dart';
import '../../../enums/exercise/core_movements_enum.dart';
import '../../../enums/routine_editor_type_enums.dart';
import '../../../screens/exercise/history/exercise_home_screen.dart';
import '../../chips/squared_chips.dart';

class ExerciseLogLiteWidget extends StatelessWidget {
  final RoutineEditorMode editorType;
  final ExerciseLogDTO exerciseLogDto;
  final ExerciseLogDTO? superSet;
  final VoidCallback onMaximise;

  const ExerciseLogLiteWidget(
      {super.key,
      this.editorType = RoutineEditorMode.edit,
      required this.exerciseLogDto,
      this.superSet,
      required this.onMaximise});

  @override
  Widget build(BuildContext context) {
    final superSetExerciseDto = superSet;

    final exerciseAndRoutineController = Provider.of<ExerciseAndRoutineController>(context);

    final exerciseVariant = exerciseLogDto.exerciseVariant;

    final exercise = exerciseAndRoutineController.whereExercise(name: exerciseVariant.name);

    return Container(
      padding: superSet == null ? const EdgeInsets.symmetric(vertical: 10, horizontal: 10) : const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: sapphireDark80, // Set the background color
        borderRadius: BorderRadius.circular(5), // Set the border radius to make it rounded
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ExerciseHomeScreen(exerciseName: exerciseLogDto.exerciseVariant.name)));
                  },
                  child: Text(exerciseLogDto.exerciseVariant.name,
                      style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                if (superSetExerciseDto != null)
                  Column(children: [
                    Text("with ${superSetExerciseDto.exerciseVariant.name}",
                        style: GoogleFonts.ubuntu(color: vibrantGreen, fontWeight: FontWeight.w500, fontSize: 12)),
                  ]),
              ],
            ),
            const Spacer(),
            IconButton(
              onPressed: onMaximise,
              icon: const Icon(Icons.expand_circle_down_rounded, color: Colors.white),
              tooltip: 'Maximise card',
            )
          ]),
          Wrap(
            runSpacing: 8,
            spacing: 8,
            children: [
              SquaredChips(
                label: exerciseVariant.equipment.name.toUpperCase(),
                color: vibrantGreen,
              ),
              if (exercise.modes.length > 1)
                SquaredChips(
                  label: exerciseVariant.mode.name.toUpperCase(),
                  color: Colors.redAccent,
                ),
              if (exercise.metrics.length > 1)
                SquaredChips(
                  label: exerciseVariant.metric.name.toUpperCase(),
                  color: vibrantBlue,
                ),
              if (exercise.positions.length > 1 &&
                  (exerciseVariant.coreMovement == CoreMovement.push ||
                      exerciseVariant.coreMovement == CoreMovement.pull))
                SquaredChips(
                  label: exerciseVariant.position.name.toUpperCase(),
                  color: Colors.cyanAccent,
                ),
              if (exercise.stances.length > 1)
                SquaredChips(
                  label: exerciseVariant.stance.name.toUpperCase(),
                  color: Colors.purpleAccent,
                ),
              if (exercise.movements.length > 1)
                SquaredChips(
                  label: exerciseVariant.movement.name.toUpperCase(),
                  color: Colors.orange,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';

import '../../../colors.dart';
import '../../../enums/routine_editor_type_enums.dart';

class ExerciseLogLiteWidget extends StatelessWidget {
  final RoutineEditorMode editorType;

  final ExerciseLogDto exerciseLogDto;
  final ExerciseLogDto? superSet;
  final VoidCallback onMaximise;

  const ExerciseLogLiteWidget(
      {super.key,
      this.editorType = RoutineEditorMode.edit,
      required this.exerciseLogDto,
      this.superSet,
      required this.onMaximise});

  @override
  Widget build(BuildContext context) {

    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final superSetExerciseDto = superSet;

    return GestureDetector(
      onTap: onMaximise,
      child: Container(
        padding: superSet == null
            ? const EdgeInsets.symmetric(vertical: 20, horizontal: 10)
            : const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: isDarkMode ? sapphireDark80 : Colors.grey.shade200, // Set the background color
          borderRadius: BorderRadius.circular(5), // Set the border radius to make it rounded
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exerciseLogDto.exercise.name,
                      style: Theme.of(context).textTheme.titleSmall),
                  if (superSetExerciseDto != null)
                    Column(children: [
                      Text("with ${superSetExerciseDto.exercise.name}",
                          style: Theme.of(context).textTheme.bodyMedium),
                    ]),
                ],
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: const FaIcon(FontAwesomeIcons.caretDown, size: 20),
              )
            ]),
          ],
        ),
      ),
    );
  }
}

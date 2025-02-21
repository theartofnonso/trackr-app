import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/enums/routine_editor_type_enums.dart';
import 'package:tracker_app/utils/navigation_utils.dart';

import '../../../colors.dart';
import '../../../utils/general_utils.dart';
import '../editors/exercise_log_widget.dart';

class ExerciseLogLiteWidget extends StatelessWidget {

  final RoutineEditorMode editorType;

  final ExerciseLogDto exerciseLogDto;
  final ExerciseLogDto? superSet;

  /// ExerciseLogDto callbacks
  final VoidCallback onRemoveLog;
  final VoidCallback onReplaceLog;
  final VoidCallback onSuperSet;
  final void Function(String superSetId) onRemoveSuperSet;

  const ExerciseLogLiteWidget(
      {super.key,
        this.editorType = RoutineEditorMode.edit,
      required this.exerciseLogDto,
      this.superSet,
      required this.onSuperSet,
      required this.onRemoveSuperSet,
      required this.onRemoveLog,
      required this.onReplaceLog});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final superSetExerciseDto = superSet;

    final checkChildren = exerciseLogDto.sets.map((setDto) => FaIcon(
      setDto.checked ? FontAwesomeIcons.solidSquareCheck : FontAwesomeIcons.solidSquareCheck,
      color: setDto.checked ? rpeIntensityToColor[setDto.rpeRating] : sapphireDark,
    )).toList();

    return GestureDetector(
      onTap: () {
        navigateWithSlideTransition(
            context: context,
            child: ExerciseLogWidget(
                exerciseLogId: exerciseLogDto.exercise.id,
                editorType: editorType));
      },
      child: Container(
        padding: EdgeInsets.only(left: 12, bottom: 12),
        decoration: BoxDecoration(
          color: isDarkMode ? sapphireDark80 : Colors.grey.shade200, // Set the background color
          borderRadius: BorderRadius.circular(5), // Set the border radius to make it rounded
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Text(exerciseLogDto.exercise.name,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                      if (superSetExerciseDto != null)
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.link,
                              size: 10,
                            ),
                            const SizedBox(width: 4),
                            Text(superSetExerciseDto.exercise.name, style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                    ],
                  ),
                ),
                MenuAnchor(
                    builder: (BuildContext context, MenuController controller, Widget? child) {
                      return IconButton(
                        onPressed: () {
                          if (controller.isOpen) {
                            controller.close();
                          } else {
                            FocusScope.of(context).unfocus();
                            controller.open();
                          }
                        },
                        icon: const Icon(Icons.more_horiz_rounded),
                        tooltip: 'Show menu',
                      );
                    },
                    menuChildren: [
                      MenuItemButton(
                        onPressed: onReplaceLog,
                        child: Text(
                          "Replace",
                          style: GoogleFonts.ubuntu(),
                        ),
                      ),
                      exerciseLogDto.superSetId.isNotEmpty
                          ? MenuItemButton(
                              onPressed: () => onRemoveSuperSet(exerciseLogDto.superSetId),
                              child: Text("Remove Super-set", style: GoogleFonts.ubuntu(color: Colors.red)),
                            )
                          : MenuItemButton(
                              onPressed: onSuperSet,
                              child: Text("Super-set", style: GoogleFonts.ubuntu()),
                            ),
                      MenuItemButton(
                        onPressed: onRemoveLog,
                        child: Text(
                          "Remove",
                          style: GoogleFonts.ubuntu(color: Colors.red),
                        ),
                      ),
                    ])
              ],
            ),
            Wrap(spacing: 8, children: checkChildren,)
          ],
        ),
      ),
    );
  }
}

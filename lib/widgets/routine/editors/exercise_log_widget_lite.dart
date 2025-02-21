import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/enums/routine_editor_type_enums.dart';
import 'package:tracker_app/utils/navigation_utils.dart';

import '../../../colors.dart';
import '../../../dtos/set_dtos/set_dto.dart';
import '../editors/exercise_log_widget.dart';

class ExerciseLogLiteWidget extends StatefulWidget {
  final ExerciseLogDto exerciseLogDto;
  final ExerciseLogDto? superSet;

  /// ExerciseLogDto callbacks
  final VoidCallback onRemoveLog;
  final VoidCallback onReplaceLog;
  final VoidCallback onSuperSet;
  final void Function(String superSetId) onRemoveSuperSet;

  const ExerciseLogLiteWidget(
      {super.key,
      required this.exerciseLogDto,
      this.superSet,
      required this.onSuperSet,
      required this.onRemoveSuperSet,
      required this.onRemoveLog,
      required this.onReplaceLog});

  @override
  State<ExerciseLogLiteWidget> createState() => _ExerciseLogLiteWidgetState();
}

class _ExerciseLogLiteWidgetState extends State<ExerciseLogLiteWidget> {
  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final superSetExerciseDto = widget.superSet;

    return GestureDetector(
      onTap: () {
        navigateWithSlideTransition(
            context: context,
            child: ExerciseLogWidget(
                exerciseLogDto: widget.exerciseLogDto,
                editorType: RoutineEditorMode.log,
                onTapWeightEditor: (SetDto setDto) {},
                onTapRepsEditor: (SetDto setDto) {}));
      },
      child: Container(
        padding: EdgeInsets.only(left: 12, top: 12, right: 2, bottom: 12),
        decoration: BoxDecoration(
          color: isDarkMode ? sapphireDark80 : Colors.grey.shade200, // Set the background color
          borderRadius: BorderRadius.circular(5), // Set the border radius to make it rounded
        ),
        child: Column(
          spacing: 12,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.exerciseLogDto.exercise.name,
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
                        onPressed: widget.onReplaceLog,
                        child: Text(
                          "Replace",
                          style: GoogleFonts.ubuntu(),
                        ),
                      ),
                      widget.exerciseLogDto.superSetId.isNotEmpty
                          ? MenuItemButton(
                              onPressed: () => widget.onRemoveSuperSet(widget.exerciseLogDto.superSetId),
                              child: Text("Remove Super-set", style: GoogleFonts.ubuntu(color: Colors.red)),
                            )
                          : MenuItemButton(
                              onPressed: widget.onSuperSet,
                              child: Text("Super-set", style: GoogleFonts.ubuntu()),
                            ),
                      MenuItemButton(
                        onPressed: widget.onRemoveLog,
                        child: Text(
                          "Remove",
                          style: GoogleFonts.ubuntu(color: Colors.red),
                        ),
                      ),
                    ])
              ],
            ),
          ],
        ),
      ),
    );
  }
}

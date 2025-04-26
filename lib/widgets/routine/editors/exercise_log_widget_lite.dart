import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/enums/routine_editor_type_enums.dart';
import 'package:tracker_app/utils/navigation_utils.dart';

import '../../../colors.dart';
import '../../../utils/dialog_utils.dart';
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

  final bool isPastRoutine;

  const ExerciseLogLiteWidget(
      {super.key,
      this.editorType = RoutineEditorMode.edit,
      required this.exerciseLogDto,
      this.superSet,
      required this.onSuperSet,
      required this.onRemoveSuperSet,
      required this.onRemoveLog,
      required this.onReplaceLog,
      this.isPastRoutine = false});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final superSetExerciseDto = superSet;

    final checkChildren = exerciseLogDto.sets
        .map((setDto) => FaIcon(
              setDto.checked ? FontAwesomeIcons.solidSquareCheck : FontAwesomeIcons.solidSquareCheck,
              color: isPastRoutine && setDto.isNotEmpty()
                  ? vibrantGreen
                  : setDto.checked
                      ? vibrantGreen
                      : Colors.grey.shade500,
            ))
        .toList();

    return GestureDetector(
      onTap: () {
        navigateWithSlideTransition(
            context: context,
            child: ExerciseLogWidget(exerciseLogId: exerciseLogDto.exercise.id, editorType: editorType));
      },
      child: Container(
        padding: EdgeInsets.only(left: 12, bottom: 12, top: superSetExerciseDto != null ? 5 : 0),
        decoration: BoxDecoration(
          color: isDarkMode ? sapphireDark80 : Colors.grey.shade200, // Set the background color
          borderRadius: BorderRadius.circular(5), // Set the border radius to make it rounded
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                          Text(superSetExerciseDto.exercise.name, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                  ],
                ),
                IconButton(onPressed: () => _showBottomSheet(context: context), icon: FaIcon(Icons.more_horiz_rounded))
              ],
            ),
            Wrap(
              spacing: 8,
              children: checkChildren,
            ),
          ],
        ),
      ),
    );
  }

  void _showBottomSheet({required BuildContext context}) {
    displayBottomSheet(
        context: context,
        child: SafeArea(
          child: Column(children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(FontAwesomeIcons.solidSquarePlus, size: 22),
              horizontalTitleGap: 6,
              title: Text("Replace"),
              onTap: () {
                Navigator.of(context).pop();
                onReplaceLog();
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(FontAwesomeIcons.link, size: 18),
              horizontalTitleGap: 6,
              title: Text("Superset"),
              onTap: () {
                Navigator.of(context).pop();
                onSuperSet();
              },
            ),
            ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const FaIcon(
                  FontAwesomeIcons.trash,
                  size: 18,
                  color: Colors.red,
                ),
                horizontalTitleGap: 6,
                title: Text("Remove",
                    style: GoogleFonts.ubuntu(color: Colors.red, fontWeight: FontWeight.w500, fontSize: 16)),
                onTap: () {
                  Navigator.of(context).pop();
                  onRemoveLog();
                }),
          ]),
        ));
  }
}

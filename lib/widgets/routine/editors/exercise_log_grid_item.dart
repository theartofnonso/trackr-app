import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../colors.dart';
import '../../../dtos/exercise_log_dto.dart';
import '../../../enums/routine_editor_type_enums.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/navigation_utils.dart';
import '../editors/exercise_log_widget.dart';

class ExerciseLogGridItemWidget extends StatelessWidget {
  final RoutineEditorMode editorType;
  final ExerciseLogDto exerciseLogDto;
  final ExerciseLogDto? superSet;

  /// ExerciseLogDto callbacks
  final VoidCallback onRemoveLog;
  final VoidCallback onReplaceLog;

  final bool isPastRoutine;

  const ExerciseLogGridItemWidget(
      {super.key,
      required this.editorType,
      required this.exerciseLogDto,
      this.superSet,
      required this.onRemoveLog,
      required this.onReplaceLog,
      this.isPastRoutine = false});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final superSetExerciseDto = superSet;

    final children = exerciseLogDto.sets
        .map((setDto) => FaIcon(
              setDto.checked
                  ? FontAwesomeIcons.solidSquareCheck
                  : FontAwesomeIcons.solidSquareCheck,
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
            child: ExerciseLogWidget(
              exerciseLogId: exerciseLogDto.exercise.id,
              editorType: editorType,
            ));
      },
      onLongPress: () => _showBottomSheet(context: context),
      child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: isDarkMode ? darkSurfaceContainer : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(radiusMD)),
          child: Column(
              spacing: 12,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(exerciseLogDto.exercise.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    if (superSetExerciseDto != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.link,
                              size: 10,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                                child: Text(superSetExerciseDto.exercise.name,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        Theme.of(context).textTheme.bodySmall)),
                          ],
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: children,
                ),
              ])),
    );
  }

  void _showBottomSheet({required BuildContext context}) {
    displayBottomSheet(
        context: context,
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
              leading: const FaIcon(
                FontAwesomeIcons.trash,
                size: 18,
                color: Colors.red,
              ),
              horizontalTitleGap: 6,
              title: Text("Remove",
                  style: GoogleFonts.ubuntu(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                      fontSize: 16)),
              onTap: () {
                Navigator.of(context).pop();
                onRemoveLog();
              }),
        ]));
  }
}

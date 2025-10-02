import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tracker_app/widgets/routine/editors/exercise_log_widget.dart';
import '../../../colors.dart';
import '../../../dtos/exercise_log_dto.dart';
import '../../../enums/routine_editor_type_enums.dart';
import '../../../utils/navigation_utils.dart';
import '../../../dtos/viewmodels/exercise_editor_arguments.dart';

class ExerciseLogListItemWidget extends StatelessWidget {
  final ExerciseLogDto exerciseLogDto;
  final RoutineEditorMode editorType;
  final ExerciseLogDto? superSet;
  final VoidCallback? onRemoveLog;
  final VoidCallback? onReplaceLog;
  final bool showConnector;
  final bool isLastItem;

  const ExerciseLogListItemWidget({
    super.key,
    required this.exerciseLogDto,
    required this.editorType,
    this.superSet,
    this.onRemoveLog,
    this.onReplaceLog,
    this.showConnector = true,
    this.isLastItem = false,
  });

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    // An exercise is completed only if all sets are checked
    final isCompleted = exerciseLogDto.sets.isNotEmpty &&
        exerciseLogDto.sets.every((set) => set.checked);

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 8.0),
          decoration: BoxDecoration(
            color: isDarkMode ? darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(radiusMD),
            border: Border.all(
              color: isDarkMode ? darkBorder : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(radiusMD),
              onTap: () => _navigateToExerciseLogEditor(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    // Checkmark circle
                    FaIcon(
                      FontAwesomeIcons.solidSquareCheck,
                      color: isCompleted ? vibrantGreen : darkBorder,
                      size: 30,
                    ),
                    const SizedBox(width: 16),

                    // Exercise info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exerciseLogDto.exercise.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isDarkMode ? darkOnSurface : Colors.black,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getExerciseInfo(),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isDarkMode
                                          ? darkOnSurfaceVariant
                                          : Colors.grey.shade600,
                                    ),
                          ),
                        ],
                      ),
                    ),

                    // Action icons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Ellipsis menu
                        IconButton(
                          onPressed: () => _showActionMenu(context),
                          icon: FaIcon(
                            FontAwesomeIcons.ellipsis,
                            size: 16,
                            color: isDarkMode
                                ? darkOnSurfaceVariant
                                : Colors.grey.shade600,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Connecting link icon (if not last item)
        if (showConnector && !isLastItem)
          Container(
            margin: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 20), // Align with checkmark circle
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.link,
                      size: 12,
                      color: isDarkMode
                          ? darkOnSurfaceVariant
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _getExerciseInfo() {
    if (exerciseLogDto.sets.isEmpty) {
      return "No sets";
    }

    final setCount = exerciseLogDto.sets.length;
    if (setCount == 1) {
      return "1 set";
    } else {
      return "$setCount sets";
    }
  }

  void _navigateToExerciseEditor(BuildContext context) {
    final arguments =
        ExerciseEditorArguments(exercise: exerciseLogDto.exercise);
    navigateToExerciseEditor(context: context, arguments: arguments);
  }

  void _navigateToExerciseLogEditor(BuildContext context) {
    navigateWithSlideTransition(
        context: context,
        child: ExerciseLogWidget(
          exerciseLogId: exerciseLogDto.exercise.id,
          editorType: editorType,
        ));
  }

  void _showActionMenu(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDarkMode ? darkSurface : Colors.white,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(radiusLG)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isDarkMode ? darkBorder : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Menu items
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.penToSquare, size: 16),
              title: const Text("Edit Exercise"),
              onTap: () {
                Navigator.pop(context);
                _navigateToExerciseEditor(context);
              },
            ),
            ListTile(
              leading:
                  const FaIcon(FontAwesomeIcons.arrowRightArrowLeft, size: 16),
              title: const Text("Replace Exercise"),
              onTap: () {
                Navigator.pop(context);
                onReplaceLog?.call();
              },
            ),

            ListTile(
              leading: FaIcon(FontAwesomeIcons.trash,
                  size: 16, color: Colors.red.shade400),
              title: Text("Remove Exercise",
                  style: TextStyle(color: Colors.red.shade400)),
              onTap: () {
                Navigator.pop(context);
                onRemoveLog?.call();
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

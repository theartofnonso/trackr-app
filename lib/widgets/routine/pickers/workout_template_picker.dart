import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/controllers/exercise_and_routine_controller.dart';
import 'package:tracker_app/dtos/db/routine_template_dto.dart';
import 'package:tracker_app/utils/navigation_utils.dart';
import 'package:tracker_app/widgets/routine/preview/routine_template_grid_item.dart';

class WorkoutTemplatePicker extends StatelessWidget {
  final String exerciseName;
  final String title;

  const WorkoutTemplatePicker({
    super.key,
    required this.exerciseName,
    this.title = "Workouts with this Exercise",
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ExerciseAndRoutineController>(
      builder: (context, controller, child) {
        final templates = controller.findTemplatesContainingExercise(
          exerciseName: exerciseName,
        );

        if (templates.isEmpty) {
          return _buildEmptyState(context);
        }

        return _buildTemplateList(context, templates);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FaIcon(
            FontAwesomeIcons.dumbbell,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            exerciseName.isEmpty
                ? "No workouts available"
                : "No workouts found",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            exerciseName.isEmpty
                ? "Create your first workout template to get started."
                : "This exercise isn't part of any workout templates yet.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateList(
      BuildContext context, List<RoutineTemplateDto> templates) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final template = templates[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: RoutineTemplateGridItemWidget(
                    template: template,
                    onTap: () {
                      Navigator.of(context).pop();
                      navigateToRoutineTemplatePreview(
                        context: context,
                        template: template,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows a bottom sheet with workout templates containing a specific exercise
void showWorkoutTemplatePicker({
  required BuildContext context,
  required String exerciseName,
  String? title,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Content
            WorkoutTemplatePicker(
              exerciseName: exerciseName,
              title: title ?? "Workouts with this Exercise",
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../colors.dart';
import '../../../controllers/exercise_and_routine_controller.dart';
import '../../../dtos/appsync/routine_template_dto.dart';
import '../../../utils/navigation_utils.dart';
import '../../../utils/string_utils.dart';

class RoutineTemplateGridItemWidget extends StatelessWidget {
  final RoutineTemplateDto template;

  const RoutineTemplateGridItemWidget({super.key, required this.template});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final exerciseAndRoutineController = Provider.of<ExerciseAndRoutineController>(context, listen: false);
    final plan = exerciseAndRoutineController.planWhere(id: template.planId);

    final exercises = template.exerciseTemplates;
    final sets = template.exerciseTemplates.expand((exercise) => exercise.sets);
    return GestureDetector(
      onTap: () => navigateToRoutineTemplatePreview(context: context, template: template),
      child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: isDarkMode ? sapphireDark80 : Colors.grey.shade200, borderRadius: BorderRadius.circular(5)),
          child: Column(spacing: 8, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                Text(
                  template.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if(plan != null)
                  Text(
                    "In ${plan.name}",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: GoogleFonts.ubuntu(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white70 : Colors.black,
                        height: 1.5,
                        fontWeight: FontWeight.w400)),
              ],
            ),
            const Spacer(),
            Column(
              spacing: 6,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: vibrantGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Image.asset(
                        'icons/dumbbells.png',
                        fit: BoxFit.contain,
                        height: 14,
                        color: vibrantGreen, // Adjust the height as needed
                      ),
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    Text(
                      "${exercises.length} ${pluralize(word: "Exercise", count: exercises.length)}",
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
                Wrap(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: vibrantBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Center(
                        child: FaIcon(
                          FontAwesomeIcons.hashtag,
                          color: vibrantBlue,
                          size: 11,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    Text(
                      "${sets.length} ${pluralize(word: "Set", count: sets.length)}",
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ],
            )
          ])),
    );
  }
}

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/extensions/dtos/routine_template_dto_extension.dart';
import 'package:tracker_app/screens/AI/trkr_coach_chat_screen.dart';
import 'package:tracker_app/utils/string_utils.dart';
import 'package:tracker_app/widgets/ai_widgets/trkr_coach_button.dart';

import '../../controllers/exercise_and_routine_controller.dart';
import '../../dtos/appsync/routine_template_dto.dart';
import '../../utils/general_utils.dart';
import '../../utils/navigation_utils.dart';
import '../../utils/routine_utils.dart';
import '../../widgets/empty_states/no_list_empty_state.dart';
import '../../widgets/information_containers/information_container_with_background_image.dart';

class RoutineTemplatesScreen extends StatelessWidget {
  const RoutineTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExerciseAndRoutineController>(builder: (_, provider, __) {
      final routineTemplates = List<RoutineTemplateDto>.from(provider.templates);

      final sortedScheduledTemplates =
          routineTemplates.where((template) => template.scheduledDays.isNotEmpty).sorted((a, b) {
        final aDayOfWeek = a.scheduledDays.first;
        final bDayOfWeek = b.scheduledDays.first;
        return aDayOfWeek.day.compareTo(bDayOfWeek.day);
      });

      final unscheduledTemplates = routineTemplates.where((template) => template.scheduledDays.isEmpty).toList();

      final templates = [...sortedScheduledTemplates, ...unscheduledTemplates];

      for (final template in templates) {
        if (template.isScheduledToday()) {
          templates.remove(template);
          templates.insert(0, template);
        }
      }

      final children = templates
          .map((template) =>
              _RoutineWidget(template: template, scheduleSummary: scheduledDaysSummary(template: template)))
          .toList();

      return Scaffold(
          floatingActionButton: FloatingActionButton(
            heroTag: "fab_routines_screen",
            onPressed: () => navigateToRoutineTemplateEditor(context: context),
            child: const FaIcon(FontAwesomeIcons.plus, size: 28),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: themeGradient(context: context),
            ),
            child: SafeArea(
                bottom: false,
                minimum: const EdgeInsets.all(10.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SizedBox(height: 16),
                  BackgroundInformationContainer(
                      image: 'images/lace.jpg',
                      containerColor: Colors.blue.shade900,
                      content: "A structured plan is essential for achieving your fitness goals. Try creating one.",
                      textStyle: GoogleFonts.ubuntu(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.9),
                      )),
                  const SizedBox(height: 16),
                  TRKRCoachButton(
                      label: "Tap to describe a workout", onTap: () => _switchToAIContext(context: context)),
                  const SizedBox(height: 16),
                  templates.isNotEmpty
                      ? Expanded(
                          child: GridView.count(
                              crossAxisCount: 2,
                              childAspectRatio: 1,
                              mainAxisSpacing: 10.0,
                              crossAxisSpacing: 10.0,
                              children: children),
                        )
                      : Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: const NoListEmptyState(
                                message:
                                    "It might feel quiet now, but tap the + button to create a workout or ask TRKR coach for help."),
                          ),
                        ),
                ])),
          ));
    });
  }

  void _switchToAIContext({required BuildContext context}) async {
    final result =
        await navigateWithSlideTransition(context: context, child: const TRKRCoachChatScreen()) as RoutineTemplateDto?;
    if (result != null) {
      if (context.mounted) {
        _saveTemplate(context: context, template: result);
      }
    }
  }

  void _saveTemplate({required BuildContext context, required RoutineTemplateDto template}) async {
    final routineTemplate = template;
    final templateController = Provider.of<ExerciseAndRoutineController>(context, listen: false);
    await templateController.saveTemplate(templateDto: routineTemplate);
  }
}

class _RoutineWidget extends StatelessWidget {
  final RoutineTemplateDto template;
  final String scheduleSummary;

  const _RoutineWidget({required this.template, required this.scheduleSummary});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final exercises = template.exerciseTemplates;
    final sets = template.exerciseTemplates.expand((exercise) => exercise.sets);
    return Badge(
      backgroundColor: vibrantGreen,
      alignment: Alignment.topRight,
      smallSize: 12,
      isLabelVisible: template.isScheduledToday(),
      child: GestureDetector(
        onTap: () => navigateToRoutineTemplatePreview(context: context, template: template),
        child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: isDarkMode ? sapphireDark80 : Colors.grey.shade200, borderRadius: BorderRadius.circular(5)),
            child: Column(spacing: 6, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                template.name,
                style: Theme.of(context).textTheme.titleMedium,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
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
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Center(
                          child: FaIcon(
                            FontAwesomeIcons.calendarDay,
                            color: Colors.deepOrange,
                            size: 11,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      Expanded(
                        child: Text(
                          scheduleSummary,
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ])),
      ),
    );
  }
}

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/extensions/dtos/routine_template_dto_extension.dart';
import 'package:tracker_app/screens/AI/trkr_coach_chat_screen.dart';
import 'package:tracker_app/strings/loading_screen_messages.dart';
import 'package:tracker_app/widgets/ai_widgets/trkr_coach_button.dart';
import 'package:tracker_app/widgets/empty_states/routine_empty_state.dart';
import 'package:tracker_app/widgets/routine/preview/routine_template_grid_item_widget.dart';

import '../../controllers/exercise_and_routine_controller.dart';
import '../../dtos/appsync/routine_template_dto.dart';
import '../../utils/navigation_utils.dart';
import '../../utils/routine_utils.dart';
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
              RoutineTemplateGridItemWidget(template: template, scheduleSummary: scheduledDaysSummary(template: template)))
          .toList();

      return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton(
            heroTag: "fab_routines_screen",
            onPressed: () => navigateToRoutineTemplateEditor(context: context),
            backgroundColor: sapphireDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: const FaIcon(FontAwesomeIcons.plus, color: Colors.white, size: 24),
          ),
          body: SafeArea(
              minimum: const EdgeInsets.only(right: 10.0, bottom: 10, left: 10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                BackgroundInformationContainer(
                    image: 'images/lace.jpg',
                    containerColor: Colors.blue.shade900,
                    content: "A structured plan is essential for achieving your fitness goals. Try creating one.",
                    textStyle: GoogleFonts.ubuntu(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.9),
                    )),
                const SizedBox(height: 16),
                TRKRCoachButton(label: "Describe a workout", onTap: () => _switchToAIContext(context: context)),
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
                    : const RoutineEmptyState(message: "Tap the + button to create workout templates"),
              ])));
    });
  }

  void _switchToAIContext({required BuildContext context}) async {
    final result = await navigateWithSlideTransition(
        context: context,
        child: const TRKRCoachChatScreen(loadingMessages: loadingTRKRCoachRoutineMessages)) as RoutineTemplateDto?;
    if (result != null) {
      if (context.mounted) {
        _saveTemplate(context: context, template: result);
      }
    }
  }

  void _saveTemplate({required BuildContext context, required RoutineTemplateDto template}) async {
    final controller = Provider.of<ExerciseAndRoutineController>(context, listen: false);
    await controller.saveTemplate(templateDto: template);
  }
}

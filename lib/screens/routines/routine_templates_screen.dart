import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/screens/AI/trkr_coach_chat_screen.dart';

import '../../controllers/exercise_and_routine_controller.dart';
import '../../dtos/appsync/routine_template_dto.dart';
import '../../utils/general_utils.dart';
import '../../utils/navigation_utils.dart';
import '../../widgets/empty_states/no_list_empty_state.dart';
import '../../widgets/information_containers/information_container_with_background_image.dart';
import '../../widgets/routine/preview/routine_template_grid_item.dart';

class RoutineTemplatesScreen extends StatelessWidget {
  static const routeName = '/routine_templates_screen';

  const RoutineTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExerciseAndRoutineController>(builder: (_, provider, __) {
      final templates = List<RoutineTemplateDto>.from(provider.templates);

      final orphanTemplates = templates.where((template) => template.planId.isEmpty);

      final children = orphanTemplates.map((template) => RoutineTemplateGridItemWidget(template: template, onTap: () => navigateToRoutineTemplatePreview(context: context, template: template))).toList();

      return Scaffold(
          body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: themeGradient(context: context),
        ),
        child: SafeArea(
          minimum: const EdgeInsets.only(top: 10, right: 10, left: 10),
          bottom: false,
          child: Column(spacing: 16, crossAxisAlignment: CrossAxisAlignment.start, children: [
            GestureDetector(
              onTap: () => _switchToAIContext(context: context),
              child: BackgroundInformationContainer(
                image: 'images/lace.jpg',
                containerColor: Colors.blue.shade900,
                content: "Need a head start on what to train? We’ve got you covered.",
                textStyle: GoogleFonts.ubuntu(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                ctaContent: 'Describe your workout',
              ),
            ),
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
          ]),
        ),
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

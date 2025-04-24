import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/screens/AI/trkr_coach_chat_screen.dart';

import '../../colors.dart';
import '../../controllers/exercise_and_routine_controller.dart';
import '../../dtos/appsync/routine_template_dto.dart';
import '../../utils/general_utils.dart';
import '../../utils/navigation_utils.dart';
import '../../widgets/empty_states/no_list_empty_state.dart';
import '../../widgets/information_containers/information_container_with_background_image.dart';
import '../../widgets/routine/preview/routine_template_grid_item.dart';

enum _AllOrOrphanTemplate {
  allTemplates(name: "All Templates", description: "Showing all workout templates."),
  orphanTemplates(name: "Not in a plan", description: "Showing workout templates not included in a plan.");

  const _AllOrOrphanTemplate({required this.name, required this.description});

  final String name;
  final String description;
}

class RoutineTemplatesScreen extends StatefulWidget {
  static const routeName = '/routine_templates_screen';

  const RoutineTemplatesScreen({super.key});

  @override
  State<RoutineTemplatesScreen> createState() => _RoutineTemplatesScreenState();
}

class _RoutineTemplatesScreenState extends State<RoutineTemplatesScreen> {
  _AllOrOrphanTemplate _allOrOrphanTemplate = _AllOrOrphanTemplate.orphanTemplates;

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return Consumer<ExerciseAndRoutineController>(builder: (_, provider, __) {
      final allTemplates = List<RoutineTemplateDto>.from(provider.templates);

      final orphanTemplates = allTemplates.where((template) => template.planId.isEmpty);

      final templates = switch (_allOrOrphanTemplate) {
        _AllOrOrphanTemplate.allTemplates => allTemplates,
        _AllOrOrphanTemplate.orphanTemplates => orphanTemplates,
      };

      final children = templates.map((template) {
        final plan = provider.planWhere(id: template.planId);

        return RoutineTemplateGridItemWidget(
            template: template, onTap: () => navigateToRoutineTemplatePreview(context: context, template: template), plan: plan,);
      }).toList();

      return Scaffold(
          body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: themeGradient(context: context),
        ),
        child: SafeArea(
          minimum: const EdgeInsets.only(top: 10, right: 10, left: 10),
          bottom: false,
          child: Column(spacing: 16, crossAxisAlignment: CrossAxisAlignment.center, children: [
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 6,
              children: [
                CupertinoSlidingSegmentedControl<_AllOrOrphanTemplate>(
                  backgroundColor: isDarkMode ? sapphireDark : Colors.grey.shade200,
                  thumbColor: isDarkMode ? sapphireDark80 : Colors.white,
                  groupValue: _allOrOrphanTemplate,
                  children: {
                    _AllOrOrphanTemplate.orphanTemplates: SizedBox(
                        width: 120,
                        child: Text(_AllOrOrphanTemplate.orphanTemplates.name,
                            style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center)),
                    _AllOrOrphanTemplate.allTemplates: SizedBox(
                        width: 120,
                        child: Text(_AllOrOrphanTemplate.allTemplates.name,
                            style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center)),
                  },
                  onValueChanged: (_AllOrOrphanTemplate? value) {
                    if (value != null) {
                      setState(() {
                        _allOrOrphanTemplate = value;
                      });
                    }
                  },
                ),
                Text(_allOrOrphanTemplate.description,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w400, color: isDarkMode ? Colors.white70 : Colors.black)),
              ],
            ),
            allTemplates.isNotEmpty
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

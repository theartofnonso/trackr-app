import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/controllers/routine_template_controller.dart';
import 'package:tracker_app/extensions/routine_template_dto_extension.dart';
import 'package:tracker_app/utils/string_utils.dart';
import 'package:tracker_app/widgets/empty_states/routine_empty_state.dart';

import '../../../dtos/routine_template_dto.dart';
import '../../../utils/general_utils.dart';
import '../../../utils/navigation_utils.dart';
import '../../../utils/routine_utils.dart';

class RoutineTemplatesScreen extends StatelessWidget {
  const RoutineTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RoutineTemplateController>(builder: (_, provider, __) {
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

      final exercise =
          routineTemplates.map((template) => template.exerciseTemplates).expand((exercises) => exercises).toList();

      final exercisesByMuscleGroupFamily = groupBy(exercise, (exercise) => exercise.exercise.primaryMuscleGroup.family);

      final muscleGroupFamilies = exercisesByMuscleGroupFamily.keys.toSet();

      final listOfPopularMuscleGroupFamilies = popularMuscleGroupFamilies().toSet();

      final untrainedMuscleGroups = listOfPopularMuscleGroupFamilies.difference(muscleGroupFamilies);

      String untrainedMuscleGroupsNames =
          joinWithAnd(items: untrainedMuscleGroups.map((muscle) => muscle.name).toList());

      final children = templates
          .map((template) =>
              _RoutineWidget(template: template, scheduleSummary: scheduledDaysSummary(template: template)))
          .toList();

      return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton(
            heroTag: "fab_routines_screen",
            onPressed: () => navigateToRoutineTemplateEditor(context: context),
            backgroundColor: sapphireDark.withOpacity(untrainedMuscleGroups.isNotEmpty ? 0.6 : 1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: const FaIcon(FontAwesomeIcons.plus, color: Colors.white, size: 28),
          ),
          body: SafeArea(
              minimum: const EdgeInsets.all(10.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                    : const RoutineEmptyState(),
                if (untrainedMuscleGroups.isNotEmpty)
                  Container(
                    width: double.infinity,
                    color: Colors.transparent,
                    child: RichText(
                        text: TextSpan(
                            text:
                                "Consider training a variety of muscle groups to avoid muscle imbalances and prevent injury. Start by including",
                            style: GoogleFonts.ubuntu(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                wordSpacing: 1,
                                height: 1.5),
                            children: [
                          const TextSpan(text: " "),
                          TextSpan(
                              text: untrainedMuscleGroupsNames,
                              style: GoogleFonts.ubuntu(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  wordSpacing: 1,
                                  height: 1.5)),
                          const TextSpan(text: " "),
                          const TextSpan(text: "exercises in your workouts."),
                        ])),
                  ),
              ])));
    });
  }
}

class _RoutineWidget extends StatelessWidget {
  final RoutineTemplateDto template;
  final String scheduleSummary;

  const _RoutineWidget({required this.template, required this.scheduleSummary});

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData(splashColor: sapphireLight),
        child: GestureDetector(
          onTap: () => navigateToRoutineTemplatePreview(context: context, template: template),
          child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                  color: sapphireDark80,
                  borderRadius: BorderRadius.circular(10),
                  gradient: template.isScheduledToday()
                      ? const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            sapphireDark80,
                            sapphireDark,
                          ],
                        )
                      : null,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5, spreadRadius: 1)]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  template.name,
                  style: GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                const Spacer(),
                Text(
                  "${template.exerciseTemplates.length} Exercises",
                  style: GoogleFonts.ubuntu(fontSize: 14, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                const SizedBox(
                  height: 6,
                ),
                Text(
                  "${template.exerciseTemplates.expand((exercise) => exercise.sets).length} Sets",
                  style: GoogleFonts.ubuntu(fontSize: 12, fontWeight: FontWeight.w400),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                Divider(color: template.isScheduledToday() ? vibrantGreen.withOpacity(0.2) : sapphireLighter, endIndent: 10),
                const SizedBox(height: 8),
                Text(
                  scheduleSummary,
                  style: GoogleFonts.ubuntu(fontSize: 14, fontWeight: FontWeight.w400),
                  overflow: TextOverflow.ellipsis,
                ),
              ])),
        ));
  }
}

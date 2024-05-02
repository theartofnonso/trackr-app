import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/controllers/routine_template_controller.dart';
import 'package:tracker_app/enums/routine_schedule_type_enums.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/extensions/routine_template_dto_extension.dart';
import 'package:tracker_app/extensions/week_days_extension.dart';
import 'package:tracker_app/utils/string_utils.dart';
import 'package:tracker_app/widgets/empty_states/routine_empty_state.dart';
import '../../../dtos/viewmodels/routine_log_arguments.dart';
import '../../../dtos/viewmodels/routine_template_arguments.dart';
import '../../../enums/routine_editor_type_enums.dart';
import '../../../utils/dialog_utils.dart';
import '../../../dtos/routine_template_dto.dart';
import '../../../utils/general_utils.dart';
import '../../../utils/navigation_utils.dart';
import '../../preferences/routine_schedule_planner/routine_schedule_planner_home.dart';

class RoutineTemplates extends StatelessWidget {
  const RoutineTemplates({super.key});

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

      for (final template in sortedScheduledTemplates) {
        if (template.isScheduledToday()) {
          sortedScheduledTemplates.remove(template);
          sortedScheduledTemplates.insert(0, template);
        }
      }

      final unscheduledTemplates = routineTemplates.where((template) => template.scheduledDays.isEmpty).toList();

      final templates = [...sortedScheduledTemplates, ...unscheduledTemplates];

      final exercise =
          routineTemplates.map((template) => template.exerciseTemplates).expand((exercises) => exercises).toList();

      final exercisesByMuscleGroupFamily = groupBy(exercise, (exercise) => exercise.exercise.primaryMuscleGroup.family);

      final muscleGroupFamilies = exercisesByMuscleGroupFamily.keys.toSet();

      final listOfPopularMuscleGroupFamilies = popularMuscleGroupFamilies().toSet();

      final untrainedMuscleGroups = listOfPopularMuscleGroupFamilies.difference(muscleGroupFamilies);

      String untrainedMuscleGroupsNames =
          joinWithAnd(items: untrainedMuscleGroups.map((muscle) => muscle.name).toList());

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
                templates.isNotEmpty
                    ? Expanded(
                        child: ListView.separated(
                            padding: const EdgeInsets.only(bottom: 150),
                            itemBuilder: (BuildContext context, int index) {
                              final template = templates[index];
                              final scheduleSummary = _scheduledDaysSummary(template: template);
                              return template.isScheduledToday()
                                  ? _RoutineBigWidget(
                                      template: template,
                                      scheduleSummary: scheduleSummary,
                                      onDelete: (context, template) =>
                                          _deleteRoutine(context: context, template: template))
                                  : _RoutineSmallWidget(
                                      template: template,
                                      scheduleSummary: scheduleSummary,
                                      onDelete: (context, template) =>
                                          _deleteRoutine(context: context, template: template));
                            },
                            separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 8),
                            itemCount: templates.length),
                      )
                    : const Expanded(child: RoutineEmptyState()),
                if (untrainedMuscleGroups.isNotEmpty)
                  Container(
                    width: double.infinity,
                    color: Colors.transparent,
                    child: RichText(
                        text: TextSpan(
                            text:
                                "Consider training a variety of muscle groups to avoid muscle imbalances and prevent injury. Start by including",
                            style: GoogleFonts.montserrat(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                wordSpacing: 1,
                                height: 1.5),
                            children: [
                          const TextSpan(text: " "),
                          TextSpan(
                              text: untrainedMuscleGroupsNames,
                              style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  wordSpacing: 1,
                                  height: 1.5)),
                          const TextSpan(text: "."),
                        ])),
                  ),
              ])));
    });
  }

  void _deleteRoutine({required BuildContext context, required RoutineTemplateDto template}) {
    Navigator.of(context).pop();
    Provider.of<RoutineTemplateController>(context, listen: false).removeTemplate(template: template).onError((_, __) {
      showSnackbar(context: context, icon: const Icon(Icons.info_outline), message: "Oops, unable to delete workout");
    });
  }
}

String _scheduledDaysSummary({required RoutineTemplateDto template}) {
  if (template.scheduleType == RoutineScheduleType.days) {
    final scheduledDays = template.scheduledDays;

    if(scheduledDays.isNotEmpty) {
      final scheduledDayNames =
      scheduledDays.map((day) => template.isScheduledToday() ? day.longName : day.shortName).toList();

      return scheduledDays.length == 7 ? "Everyday" : "Every ${joinWithAnd(items: scheduledDayNames)}";
    }
  }

  if(template.scheduleIntervals >= 1) {
    return template.scheduleIntervals == 1
        ? "Everyday"
        : "Next on ${template.scheduledDate?.formattedDate()}";
  }
  return "No schedule";
}

class _RoutineBigWidget extends StatelessWidget {
  final RoutineTemplateDto template;
  final String scheduleSummary;
  final void Function(BuildContext context, RoutineTemplateDto template) onDelete;

  const _RoutineBigWidget({required this.template, required this.onDelete, required this.scheduleSummary});

  @override
  Widget build(BuildContext context) {
    final menuActions = [
      MenuItemButton(
        onPressed: () {
          final arguments = RoutineTemplateArguments(template: template);
          navigateToRoutineTemplateEditor(context: context, arguments: arguments);
        },
        child: Text("Edit", style: GoogleFonts.montserrat(color: Colors.white)),
      ),
      MenuItemButton(
        onPressed: () {
          displayBottomSheet(
              height: 400,
              context: context,
              child: RoutineSchedulePlannerHome(template: template),
              isScrollControlled: true);
        },
        child: Text("Schedule", style: GoogleFonts.montserrat(color: Colors.white)),
      ),
      MenuItemButton(
        onPressed: () {
          showBottomSheetWithMultiActions(
              context: context,
              title: 'Delete ${template.name}?',
              description: 'Are you sure you want to delete this workout?',
              leftAction: Navigator.of(context).pop,
              rightAction: () => onDelete(context, template),
              leftActionLabel: 'Cancel',
              rightActionLabel: 'Delete',
              isRightActionDestructive: true);
        },
        child: Text("Delete", style: GoogleFonts.montserrat(color: Colors.red)),
      )
    ];

    return Theme(
        data: ThemeData(splashColor: sapphireLight),
        child: GestureDetector(
          onTap: () => navigateToRoutineTemplatePreview(context: context, template: template),
          child: Container(
            decoration: BoxDecoration(
                color: sapphireDark80,
                borderRadius: BorderRadius.circular(5),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    sapphireDark80,
                    sapphireDark,
                  ],
                ),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5, spreadRadius: 1)]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  tileColor: Colors.transparent,
                  dense: true,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  title: Text(template.name, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14)),
                  trailing: MenuAnchor(
                    style: MenuStyle(
                      backgroundColor: MaterialStateProperty.all(sapphireDark80),
                      surfaceTintColor: MaterialStateProperty.all(sapphireDark),
                    ),
                    builder: (BuildContext context, MenuController controller, Widget? child) {
                      return IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          if (controller.isOpen) {
                            controller.close();
                          } else {
                            controller.open();
                          }
                        },
                        icon: const Icon(
                          Icons.more_horiz_rounded,
                          color: Colors.white70,
                          size: 24,
                        ),
                        tooltip: 'Show menu',
                      );
                    },
                    menuChildren: menuActions,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 22, left: 18.0, bottom: 12),
                  child: Row(
                    children: [
                      if (scheduleSummary.isNotEmpty)
                        Row(
                          children: [
                            const FaIcon(FontAwesomeIcons.solidBell, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            SizedBox(
                              width: 150,
                              child: Text(scheduleSummary,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.montserrat(
                                      color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      const Spacer(),
                      GestureDetector(
                          onTap: () {
                            final arguments =
                                RoutineLogArguments(log: template.log(), editorMode: RoutineEditorMode.log);
                            navigateToRoutineLogEditor(context: context, arguments: arguments);
                          },
                          child: const Icon(
                            Icons.play_circle_fill_rounded,
                            color: vibrantGreen,
                            size: 35,
                          )),
                      const SizedBox(width: 26),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

class _RoutineSmallWidget extends StatelessWidget {
  final RoutineTemplateDto template;
  final String scheduleSummary;
  final void Function(BuildContext context, RoutineTemplateDto template) onDelete;

  const _RoutineSmallWidget({required this.template, required this.onDelete, required this.scheduleSummary});

  @override
  Widget build(BuildContext context) {
    final menuActions = [
      MenuItemButton(
        onPressed: () {
          final arguments = RoutineTemplateArguments(template: template);
          navigateToRoutineTemplateEditor(context: context, arguments: arguments);
        },
        child: Text("Edit", style: GoogleFonts.montserrat(color: Colors.white)),
      ),
      MenuItemButton(
        onPressed: () {
          displayBottomSheet(
              height: 400,
              context: context,
              child: RoutineSchedulePlannerHome(template: template),
              isScrollControlled: true);
        },
        child: Text("Schedule", style: GoogleFonts.montserrat(color: Colors.white)),
      ),
      MenuItemButton(
        onPressed: () {
          showBottomSheetWithMultiActions(
              context: context,
              title: 'Delete ${template.name}?',
              description: 'Are you sure you want to delete this workout?',
              leftAction: Navigator.of(context).pop,
              rightAction: () => onDelete(context, template),
              leftActionLabel: 'Cancel',
              rightActionLabel: 'Delete',
              isRightActionDestructive: true);
        },
        child: Text("Delete", style: GoogleFonts.montserrat(color: Colors.red)),
      )
    ];

    return Theme(
        data: ThemeData(splashColor: sapphireLight),
        child: GestureDetector(
          onTap: () => navigateToRoutineTemplatePreview(context: context, template: template),
          child: Container(
            decoration: BoxDecoration(
                color: sapphireDark80,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5, spreadRadius: 1)]),
            child: ListTile(
              tileColor: Colors.transparent,
              dense: true,
              leading: GestureDetector(
                  onTap: () {
                    final arguments = RoutineLogArguments(log: template.log(), editorMode: RoutineEditorMode.log);
                    navigateToRoutineLogEditor(context: context, arguments: arguments);
                  },
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 35,
                  )),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              title: Text(template.name, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14)),
              subtitle: scheduleSummary.isNotEmpty ? Row(
                children: [
                  const FaIcon(FontAwesomeIcons.solidBell, color: Colors.white, size: 10),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 120,
                    child: Text(scheduleSummary,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                            color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                  ),
                ],
              ) : null,
              trailing: MenuAnchor(
                style: MenuStyle(
                  backgroundColor: MaterialStateProperty.all(sapphireDark80),
                  surfaceTintColor: MaterialStateProperty.all(sapphireDark),
                ),
                builder: (BuildContext context, MenuController controller, Widget? child) {
                  return IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    },
                    icon: const Icon(
                      Icons.more_horiz_rounded,
                      color: Colors.white70,
                      size: 24,
                    ),
                    tooltip: 'Show menu',
                  );
                },
                menuChildren: menuActions,
              ),
            ),
          ),
        ));
  }
}

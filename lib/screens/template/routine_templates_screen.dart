import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/controllers/routine_template_controller.dart';
import 'package:tracker_app/utils/string_utils.dart';
import 'package:tracker_app/widgets/empty_states/routine_empty_state.dart';
import '../../dtos/viewmodels/routine_log_arguments.dart';
import '../../dtos/viewmodels/routine_template_arguments.dart';
import '../../enums/routine_editor_type_enums.dart';
import '../../utils/dialog_utils.dart';
import '../../dtos/routine_template_dto.dart';
import '../../utils/general_utils.dart';
import '../../utils/navigation_utils.dart';

class RoutineTemplatesScreen extends StatelessWidget {
  const RoutineTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RoutineTemplateController>(builder: (_, provider, __) {
      final routineTemplates = provider.templates;

      final exercise = routineTemplates.map((template) => template.exercises).expand((exercises) => exercises).toList();

      final exercisesByMuscleGroupFamily = groupBy(exercise, (exercise) => exercise.exercise.primaryMuscleGroup.family);

      final muscleGroupFamilies = exercisesByMuscleGroupFamily.keys.toSet();

      final listOfPopularMuscleGroupFamilies = popularMuscleGroupFamilies().toSet();

      final untrainedMuscleGroups = listOfPopularMuscleGroupFamilies.difference(muscleGroupFamilies);

      String untrainedMuscleGroupsNames = "";

      if (untrainedMuscleGroups.isNotEmpty) {
        if (untrainedMuscleGroups.length > 1) {
          untrainedMuscleGroupsNames =
              "${untrainedMuscleGroups.take(untrainedMuscleGroups.length - 1).map((muscle) => muscle.name).join(", ")} and ${untrainedMuscleGroups.last.name}";
        } else {
          untrainedMuscleGroupsNames = untrainedMuscleGroups.first.name;
        }
      }

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
                routineTemplates.isNotEmpty
                    ? Expanded(
                        child: ListView.separated(
                            padding: const EdgeInsets.only(bottom: 150),
                            itemBuilder: (BuildContext context, int index) => _RoutineWidget(
                                  template: routineTemplates[index],
                                ),
                            separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 8),
                            itemCount: routineTemplates.length),
                      )
                    : const Expanded(child: RoutineEmptyState()),
                if (untrainedMuscleGroups.isNotEmpty)
                  Container(
                    width: double.infinity,
                    color: sapphireDark,
                    padding: const EdgeInsets.all(10),
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
}

class _RoutineWidget extends StatelessWidget {
  final RoutineTemplateDto template;

  const _RoutineWidget({required this.template});

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
          showBottomSheetWithMultiActions(
              context: context,
              title: 'Delete workout?',
              description: 'Are you sure you want to delete this workout?',
              leftAction: Navigator.of(context).pop,
              rightAction: () {
                Navigator.of(context).pop();
                _deleteRoutine(context);
              },
              leftActionLabel: 'Cancel',
              rightActionLabel: 'Delete',
              isRightActionDestructive: true);
        },
        child: Text("Delete", style: GoogleFonts.montserrat(color: Colors.red)),
      )
    ];

    return Theme(
        data: ThemeData(splashColor: sapphireLight),
        child: ListTile(
          tileColor: sapphireDark80,
          onTap: () => navigateToRoutineTemplatePreview(context: context, template: template),
          dense: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
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
          title: Text(template.name, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14)),
          subtitle: Text(
              "${template.exercises.length} ${pluralize(word: "exercise", count: template.exercises.length)}",
              style: GoogleFonts.montserrat(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500)),
          trailing: MenuAnchor(
            style: MenuStyle(
              backgroundColor: MaterialStateProperty.all(sapphireDark80),
              surfaceTintColor: MaterialStateProperty.all(sapphireDark),
            ),
            builder: (BuildContext context, MenuController controller, Widget? child) {
              return IconButton(
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                tooltip: 'Show menu',
              );
            },
            menuChildren: menuActions,
          ),
        ));
  }

  void _deleteRoutine(BuildContext context) {
    Provider.of<RoutineTemplateController>(context, listen: false).removeTemplate(template: template).onError((_, __) {
      showSnackbar(context: context, icon: const Icon(Icons.info_outline), message: "Oops, unable to delete workout");
    });
  }
}

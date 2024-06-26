import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/enums/routine_preview_type_enum.dart';
import 'package:tracker_app/extensions/week_days_extension.dart';

import '../../../../colors.dart';
import '../../../../dtos/exercise_log_dto.dart';
import '../../../controllers/routine_template_controller.dart';
import '../../../dtos/routine_template_dto.dart';
import '../../../dtos/viewmodels/routine_log_arguments.dart';
import '../../../dtos/viewmodels/routine_template_arguments.dart';
import '../../../enums/routine_editor_type_enums.dart';
import '../../../enums/routine_template_type_enum.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/routine_utils.dart';
import '../../../dtos/viewmodels/exercise_log_view_model.dart';
import '../../../utils/navigation_utils.dart';
import '../../../utils/string_utils.dart';
import '../../../widgets/backgrounds/overlay_background.dart';
import '../../../widgets/routine/preview/exercise_log_listview.dart';
import '../../preferences/routine_schedule_planner.dart';

class RoutineTemplate extends StatefulWidget {
  final RoutineTemplateTypeEnum templateType;
  final RoutineTemplateDto template;

  const RoutineTemplate(
      {super.key, this.templateType = RoutineTemplateTypeEnum.customTemplate, required this.template});

  @override
  State<RoutineTemplate> createState() => _RoutineTemplateState();
}

class _RoutineTemplateState extends State<RoutineTemplate> {
  bool _loading = false;

  void _deleteRoutine() async {
    try {
      await Provider.of<RoutineTemplateController>(context, listen: false).removeTemplate(template: widget.template);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        showSnackbar(context: context, icon: const Icon(Icons.info_outline), message: "Unable to remove workout");
      }
    } finally {
      _toggleLoadingState();
    }
  }

  void _toggleLoadingState() {
    setState(() {
      _loading = !_loading;
    });
  }

  @override
  Widget build(BuildContext context) {
    final routineTemplateController = Provider.of<RoutineTemplateController>(context, listen: true);

    RoutineTemplateDto? template = routineTemplateController.templateWhere(id: widget.template.id);

    if (template == null) {
      return const SizedBox.shrink();
    }

    final menuActions = [
      MenuItemButton(
          onPressed: () {
            final arguments = RoutineTemplateArguments(template: template);
            navigateToRoutineTemplateEditor(context: context, arguments: arguments);
          },
          child: Text("Edit", style: GoogleFonts.montserrat())),
      MenuItemButton(
        onPressed: () {
          displayBottomSheet(
              context: context, child: RoutineSchedulePlanner(template: template), isScrollControlled: true);
        },
        child: Text("Schedule", style: GoogleFonts.montserrat(color: Colors.white)),
      ),
      MenuItemButton(
        onPressed: () {
          showBottomSheetWithMultiActions(
              context: context,
              title: "Delete workout?",
              description: "Are you sure you want to delete this workout?",
              leftAction: Navigator.of(context).pop,
              rightAction: () {
                Navigator.of(context).pop();
                _toggleLoadingState();
                _deleteRoutine();
              },
              leftActionLabel: 'Cancel',
              rightActionLabel: 'Delete',
              isRightActionDestructive: true);
        },
        child: Text("Delete", style: GoogleFonts.montserrat(color: Colors.red)),
      )
    ];

    final scheduledDays = template.days;

    final otherScheduledDayNames = scheduledDays.map((day) => day.shortName).toList();

    final otherScheduledDays =
        scheduledDays.length == 7 ? "Scheduled everyday" : "Scheduled on ${joinWithAnd(items: otherScheduledDayNames)}";

    return Scaffold(
        floatingActionButton: FloatingActionButton(
            heroTag: UniqueKey,
            onPressed: () {
              final arguments = RoutineLogArguments(log: template.log(), editorMode: RoutineEditorMode.log);
              navigateToRoutineLogEditor(context: context, arguments: arguments);
            },
            backgroundColor: sapphireDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: const Icon(Icons.play_arrow)),
        backgroundColor: sapphireDark,
        appBar: AppBar(
          backgroundColor: sapphireDark80,
          leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(template.name,
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)),
          actions: [
            MenuAnchor(
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
                    Icons.more_vert_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  tooltip: 'Show menu',
                );
              },
              menuChildren: menuActions,
            )
          ],
        ),
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                sapphireDark80,
                sapphireDark,
              ],
            ),
          ),
          child: Stack(children: [
            SafeArea(
              minimum: const EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (template.notes.isNotEmpty)
                      Column(
                        children: [
                          Text(template.notes,
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 14,
                              )),
                          const SizedBox(height: 5),
                        ],
                      ),
                    if (scheduledDays.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const FaIcon(FontAwesomeIcons.solidBell, color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(otherScheduledDays,
                              style: GoogleFonts.montserrat(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              )),
                        ],
                      ),
                    ExerciseLogListView(
                      exerciseLogs: _exerciseLogsToViewModels(exerciseLogs: template.exerciseTemplates),
                      previewType: RoutinePreviewType.template,
                    ),
                  ],
                ),
              ),
            ),
            if (_loading) const OverlayBackground()
          ]),
        ));
  }

  List<ExerciseLogViewModel> _exerciseLogsToViewModels({required List<ExerciseLogDto> exerciseLogs}) {
    return exerciseLogs.map((exerciseLog) {
      return ExerciseLogViewModel(
          exerciseLog: exerciseLog,
          superSet: whereOtherExerciseInSuperSet(firstExercise: exerciseLog, exercises: exerciseLogs));
    }).toList();
  }
}

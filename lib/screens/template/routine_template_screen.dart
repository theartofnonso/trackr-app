
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/enums/routine_preview_type_enum.dart';

import '../../../app_constants.dart';
import '../../../dtos/exercise_log_dto.dart';
import '../../controllers/routine_template_controller.dart';
import '../../dtos/routine_template_dto.dart';
import '../../enums/routine_editor_type_enums.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/routine_utils.dart';
import '../../dtos/viewmodels/exercise_log_view_model.dart';
import '../../utils/navigation_utils.dart';
import '../../widgets/backgrounds/overlay_background.dart';
import '../../widgets/routine/preview/exercise_log_listview.dart';

class RoutineTemplateScreen extends StatefulWidget {
  final RoutineTemplateDto template;

  const RoutineTemplateScreen({super.key, required this.template});

  @override
  State<RoutineTemplateScreen> createState() => _RoutineTemplateScreenState();
}

class _RoutineTemplateScreenState extends State<RoutineTemplateScreen> {
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

    final template = Provider.of<RoutineTemplateController>(context, listen: true).templateWhere(id: widget.template.id);

    if (template == null) {
      return const SizedBox.shrink();
    }

    final menuActions = [
      MenuItemButton(
          onPressed: () {
            navigateToRoutineEditor(context: context, template: template);
          },
          child: Text("Edit", style: GoogleFonts.montserrat())),
      MenuItemButton(
        onPressed: () {
          showAlertDialogWithMultiActions(
              context: context,
              message: "Delete workout?",
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

    return Scaffold(
        floatingActionButton: FloatingActionButton(
            heroTag: "fab_routine_preview_screen",
            onPressed: () => navigateToRoutineLogEditor(context: context, log: template.log(), editorMode: RoutineEditorMode.log),
            backgroundColor: tealBlueLighter,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: const Icon(Icons.play_arrow)),
        backgroundColor: tealBlueDark,
        appBar: AppBar(
          leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(template.name,
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)),
          actions: [
            MenuAnchor(
              style: MenuStyle(
                backgroundColor: MaterialStateProperty.all(tealBlueLighter),
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
        body: Stack(children: [
          SafeArea(
            minimum: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  template.notes.isNotEmpty
                      ? Text(template.notes,
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 14,
                      ))
                      : const SizedBox.shrink(),
                  const SizedBox(height: 5),
                  ExerciseLogListView(exerciseLogs: _exerciseLogsToViewModels(exerciseLogs: template.exercises), previewType: RoutinePreviewType.template,),
                ],
              ),
            ),
          ),
          if (_loading) const OverlayBackground(loadingMessage: "Deleting workout...")
        ]));
  }

  List<ExerciseLogViewModel> _exerciseLogsToViewModels({required List<ExerciseLogDto> exerciseLogs}) {
    return exerciseLogs.map((exerciseLog) {
      return ExerciseLogViewModel(
          exerciseLog: exerciseLog,
          superSet: whereOtherExerciseInSuperSet(firstExercise: exerciseLog, exercises: exerciseLogs));
    }).toList();
  }
}

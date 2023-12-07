import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/models/ModelProvider.dart';
import 'package:tracker_app/screens/editors/routine_editor_screen.dart';
import 'package:tracker_app/utils/snackbar_utils.dart';
import 'package:tracker_app/widgets/routine/preview/exercise_log_widget.dart';

import '../../../app_constants.dart';
import '../../../dtos/exercise_log_dto.dart';
import '../../../providers/routine_log_provider.dart';
import '../../../providers/routine_provider.dart';
import '../../../widgets/helper_widgets/dialog_helper.dart';
import '../../../widgets/helper_widgets/routine_helper.dart';
import '../../providers/exercise_provider.dart';
import '../../utils/navigation_utils.dart';

enum RoutineSummaryType { volume, reps, duration }

class RoutinePreviewScreen extends StatefulWidget {
  final String routineId;

  const RoutinePreviewScreen({super.key, required this.routineId});

  @override
  State<RoutinePreviewScreen> createState() => _RoutinePreviewScreenState();
}

class _RoutinePreviewScreenState extends State<RoutinePreviewScreen> {
  bool _loading = false;

  /// [MenuItemButton]
  List<Widget> _menuActionButtons({required Routine routine}) {
    return [
      MenuItemButton(
        onPressed: () {
          navigateToRoutineEditor(context: context, routine: routine, mode: RoutineEditorMode.edit);
        },
        //leadingIcon: const Icon(Icons.edit),
        child: const Text("Edit"),
      ),
      MenuItemButton(
        onPressed: () {
          showAlertDialog(
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
        //leadingIcon: const Icon(Icons.delete_sweep, color: Colors.red),
        child: Text("Delete", style: GoogleFonts.lato(color: Colors.red)),
      )
    ];
  }

  void _deleteRoutine() async {
    try {
      await Provider.of<RoutineProvider>(context, listen: false).removeRoutine(id: widget.routineId);
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
    final routine = Provider.of<RoutineProvider>(context, listen: true).routineWhere(id: widget.routineId);

    if (routine == null) {
      return const SizedBox.shrink();
    }

    List<ExerciseLogDto> procedures =
    routine.procedures.map((json) => ExerciseLogDto.fromJson(json: jsonDecode(json))).map((procedure) {
      final exerciseFromLibrary =
      Provider.of<ExerciseProvider>(context, listen: false).whereExerciseOrNull(exerciseId: procedure.exercise.id);
      if (exerciseFromLibrary != null) {
        return procedure.copyWith(exercise: exerciseFromLibrary);
      }
      return procedure;
    }).toList();

    final cachedRoutineLogDto = Provider.of<RoutineLogProvider>(context, listen: true).cachedLog;

    return Scaffold(
        floatingActionButton: cachedRoutineLogDto == null
            ? FloatingActionButton(
                heroTag: "fab_routine_preview_screen",
                onPressed: () {
                  navigateToRoutineEditor(context: context, routine: routine, mode: RoutineEditorMode.log);
                },
                backgroundColor: tealBlueLighter,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                child: const Icon(Icons.play_arrow))
            : null,
        backgroundColor: tealBlueDark,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_outlined),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(routine.name,
              style: GoogleFonts.lato(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)),
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
              menuChildren: _menuActionButtons(routine: routine),
            )
          ],
        ),
        body: Stack(children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(right: 10, bottom: 10, left: 10),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    routine.notes.isNotEmpty
                        ? Text(routine.notes,
                            style: GoogleFonts.lato(
                              color: Colors.white,
                              fontSize: 14,
                            ))
                        : const SizedBox.shrink(),
                    const SizedBox(height: 5),
                    ..._proceduresToWidgets(procedures: procedures)
                  ],
                ),
              ),
            ),
          ),
          _loading
              ? Align(
                  alignment: Alignment.center,
                  child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: tealBlueDark.withOpacity(0.7),
                      child: Center(child: Text("Deleting workout", style: GoogleFonts.lato(fontSize: 14)))))
              : const SizedBox.shrink()
        ]));
  }

  List<Widget> _proceduresToWidgets({required List<ExerciseLogDto> procedures}) {
    return procedures
        .map((procedure) => Column(
              children: [
                ExerciseLogWidget(
                  exerciseLog: procedure,
                  superSet: whereOtherSuperSetProcedure(firstProcedure: procedure, procedures: procedures),
                ),
                const SizedBox(height: 18)
              ],
            ))
        .toList();
  }
}

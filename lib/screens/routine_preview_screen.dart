import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/screens/routine_editor_screen.dart';
import 'package:tracker_app/widgets/routine/preview/procedure_widget.dart';

import '../app_constants.dart';
import '../dtos/procedure_dto.dart';
import '../models/Routine.dart';
import '../providers/routine_log_provider.dart';
import '../providers/routine_provider.dart';
import '../widgets/helper_widgets/routine_helper.dart';

class RoutinePreviewScreen extends StatelessWidget {
  final String routineId;

  const RoutinePreviewScreen({super.key, required this.routineId});

  /// [MenuItemButton]
  List<Widget> _menuActionButtons({required BuildContext context, required Routine routine}) {
    return [
      MenuItemButton(
        onPressed: () {
          _navigateToRoutineEditor(context: context, routine: routine, mode: RoutineEditorMode.editing);
        },
        leadingIcon: const Icon(Icons.edit),
        child: const Text("Edit"),
      ),
      MenuItemButton(
        onPressed: () {
          Navigator.of(context).pop({"id": routineId});
        },
        leadingIcon: const Icon(Icons.delete_sweep, color: Colors.red),
        child: const Text("Delete", style: TextStyle(color: Colors.red)),
      )
    ];
  }

  void _navigateToRoutineEditor(
      {required BuildContext context, required Routine routine, RoutineEditorMode mode = RoutineEditorMode.editing}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => RoutineEditorScreen(routine: routine, mode: mode, type: RoutineEditingType.template)));
  }

  /// Convert list of [ExerciseInWorkout] to [ExerciseInWorkoutEditor]
  Widget _procedureToWidget({required ProcedureDto procedure, required List<ProcedureDto> otherProcedures}) {
    return ProcedureWidget(
      procedureDto: procedure,
      otherSuperSetProcedureDto: whereOtherSuperSetProcedure(firstProcedure: procedure, procedures: otherProcedures),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routine = Provider.of<RoutineProvider>(context, listen: true).whereRoutineDto(id: routineId);

    if (routine != null) {
      final procedures = routine.procedures.map((json) => ProcedureDto.fromJson(jsonDecode(json), context)).toList();

      final cachedRoutineLogDto = Provider.of<RoutineLogProvider>(context, listen: true).cachedLog;

      return Scaffold(
          floatingActionButton: cachedRoutineLogDto == null
              ? FloatingActionButton(
                  heroTag: "fab_routine_preview_screen",
                  onPressed: () {
                    _navigateToRoutineEditor(context: context, routine: routine, mode: RoutineEditorMode.routine);
                  },
                  backgroundColor: tealBlueLighter,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  child: const Icon(Icons.play_arrow))
              : null,
          backgroundColor: tealBlueDark,
          appBar: AppBar(
            backgroundColor: tealBlueDark,
            title: Text(routine.name,
                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)),
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
                menuChildren: _menuActionButtons(context: context, routine: routine),
              )
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(right: 10, bottom: 10, left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  routine.notes.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Text(routine.notes,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              )),
                        )
                      : const SizedBox.shrink(),
                  // Padding(
                  //   padding: const EdgeInsets.only(top: 20.0, right: 30, bottom: 20),
                  //   child: LineChartWidget(chartPoints: _chartPoints, dateTimes: _dateTimes),
                  // ),
                  Expanded(
                    child: ListView.separated(
                        itemBuilder: (BuildContext context, int index) => _procedureToWidget(
                            procedure: ProcedureDto.fromJson(jsonDecode(routine.procedures[index]), context),
                            otherProcedures: procedures),
                        separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 18),
                        itemCount: routine.procedures.length),
                  ),
                ],
              ),
            ),
          ));
    }

    return const SizedBox.shrink();
  }
}

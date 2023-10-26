import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/routine_dto.dart';
import 'package:tracker_app/screens/routine_editor_screen.dart';
import 'package:tracker_app/widgets/routine/preview/procedure_widget.dart';

import '../app_constants.dart';
import '../dtos/procedure_dto.dart';
import '../providers/routine_log_provider.dart';
import '../providers/routine_provider.dart';

class RoutinePreviewScreen extends StatelessWidget {
  final String routineId;

  const RoutinePreviewScreen({super.key, required this.routineId});

  /// [MenuItemButton]
  List<Widget> _menuActionButtons({required BuildContext context, required RoutineDto routineDto}) {
    return [
      MenuItemButton(
        onPressed: () {
          _navigateToRoutineEditor(context: context, routineDto: routineDto, mode: RoutineEditorMode.editing);
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
      {required BuildContext context,
      required RoutineDto routineDto,
      RoutineEditorMode mode = RoutineEditorMode.editing}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            RoutineEditorScreen(routineDto: routineDto, mode: mode, type: RoutineEditingType.template)));
  }

  /// Convert list of [ExerciseInWorkout] to [ExerciseInWorkoutEditor]
  Widget _procedureToWidget({required ProcedureDto procedure, required List<ProcedureDto> otherProcedures}) {
    return ProcedureWidget(
      procedureDto: procedure,
      otherSuperSetProcedureDto: _whereOtherProcedure(firstProcedure: procedure, procedures: otherProcedures),
    );
  }

  ProcedureDto? _whereOtherProcedure({required ProcedureDto firstProcedure, required List<ProcedureDto> procedures}) {
    return procedures.firstWhereOrNull((procedure) =>
        procedure.superSetId.isNotEmpty &&
        procedure.superSetId == firstProcedure.superSetId &&
        procedure.exercise.id != firstProcedure.exercise.id);
  }

  @override
  Widget build(BuildContext context) {
    final routineDto = Provider.of<RoutineProvider>(context, listen: true).whereRoutineDto(id: routineId);

    final cachedRoutineLogDto = Provider.of<RoutineLogProvider>(context, listen: true).cachedLogDto;

    return routineDto != null
        ? Scaffold(
            floatingActionButton: cachedRoutineLogDto == null
                ? FloatingActionButton(
                    onPressed: () {
                      _navigateToRoutineEditor(
                          context: context, routineDto: routineDto, mode: RoutineEditorMode.routine);
                    },
                    backgroundColor: tealBlueLighter,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    child: const Icon(Icons.play_arrow))
                : null,
            backgroundColor: tealBlueDark,
            appBar: AppBar(
              backgroundColor: tealBlueDark,
              title: Text(routineDto.name,
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
                  menuChildren: _menuActionButtons(context: context, routineDto: routineDto),
                )
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(right: 10, bottom: 10, left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    routineDto.notes.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Text(routineDto.notes,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                )),
                          )
                        : const SizedBox.shrink(),
                    Expanded(
                      child: ListView.separated(
                          itemBuilder: (BuildContext context, int index) => _procedureToWidget(
                              procedure: routineDto.procedures[index], otherProcedures: routineDto.procedures),
                          separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 18),
                          itemCount: routineDto.procedures.length),
                    ),
                  ],
                ),
              ),
            ))
        : const SizedBox.shrink();
  }
}

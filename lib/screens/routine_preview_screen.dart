
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/routine_dto.dart';
import 'package:tracker_app/screens/routine_editor_screen.dart';
import 'package:tracker_app/widgets/routine/preview/procedure_widget.dart';

import '../app_constants.dart';
import '../dtos/procedure_dto.dart';
import '../providers/routine_provider.dart';

class RoutinePreviewScreen extends StatelessWidget {
  final String routineId;

  const RoutinePreviewScreen({super.key, required this.routineId});

  /// Show [CupertinoActionSheet]
  void _showWorkoutPreviewActionSheet({required BuildContext context, required RoutineDto routineDto}) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(color: tealBlueDark);
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _navigateToRoutineEditor(context: context, routineDto: routineDto, mode: RoutineEditorMode.editing);
            },
            child: Text('Edit', style: textStyle),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _removeRoutine(context: context, routineDto: routineDto);
            },
            child: const Text('Delete', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _navigateToRoutineEditor(
      {required BuildContext context, required RoutineDto routineDto, RoutineEditorMode mode = RoutineEditorMode.editing}) {
    Navigator.of(context)
        .push(CupertinoPageRoute(builder: (context) => RoutineEditorScreen(routineDto: routineDto, mode: mode)));
  }

  void _removeRoutine({required BuildContext context, required RoutineDto routineDto}) {
    Provider.of<RoutineProvider>(context, listen: false).removeRoutine(id: routineDto.id);
  }

  /// Convert list of [ExerciseInWorkout] to [ExerciseInWorkoutEditor]
  ProcedureWidget _procedureToWidget({required ProcedureDto procedure, required List<ProcedureDto> otherProcedures}) {
    return ProcedureWidget(
      procedureDto: procedure,
      otherSuperSetProcedureDto: _whereOtherProcedure(firstProcedure: procedure, procedures: otherProcedures),
    );
  }

  ProcedureDto? _whereOtherProcedure({required ProcedureDto firstProcedure, required List<ProcedureDto> procedures}) {
    return procedures.firstWhereOrNull((procedure) =>
        procedure.superSetId == firstProcedure.superSetId && procedure.exercise.id != firstProcedure.exercise.id);
  }

  @override
  Widget build(BuildContext context) {
    final routineDto = Provider.of<RoutineProvider>(context, listen: true).whereRoutineDto(id: routineId);

    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () =>
              _navigateToRoutineEditor(context: context, routineDto: routineDto, mode: RoutineEditorMode.routine),
          backgroundColor: tealBlueLighter,
          child: const Icon(CupertinoIcons.play_arrow_solid),
        ),
        backgroundColor: tealBlueDark,
        appBar: CupertinoNavigationBar(
          backgroundColor: tealBlueDark,
          trailing: GestureDetector(
              onTap: () => _showWorkoutPreviewActionSheet(context: context, routineDto: routineDto),
              child: const Icon(
                CupertinoIcons.ellipsis_vertical,
                color: CupertinoColors.white,
                size: 24,
              )),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(right: 10, bottom: 10, left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CupertinoListSection.insetGrouped(
                  hasLeading: false,
                  margin: EdgeInsets.zero,
                  backgroundColor: Colors.transparent,
                  children: [
                    CupertinoListTile(
                      backgroundColor: tealBlueLight,
                      title: Text(routineDto.name,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.white.withOpacity(0.8),
                              fontSize: 18)),
                    ),
                    CupertinoListTile(
                      backgroundColor: tealBlueLight,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      title: Text(routineDto.notes,
                          style: TextStyle(
                            height: 1.5,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.white.withOpacity(0.8),
                            fontSize: 16,
                          )),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                      itemBuilder: (BuildContext context, int index) =>  _procedureToWidget(procedure: routineDto.procedures[index], otherProcedures: routineDto.procedures),
                      separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 12),
                      itemCount: routineDto.procedures.length),
                ),
              ],
            ),
          ),
        ));
  }
}

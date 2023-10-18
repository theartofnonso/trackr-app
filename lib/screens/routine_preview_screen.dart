import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/screens/routine_editor_screen.dart';
import 'package:tracker_app/widgets/workout/preview/procedure_widget.dart';

import '../app_constants.dart';
import '../dtos/procedure_dto.dart';
import '../dtos/routine_dto.dart';
import '../providers/routine_provider.dart';

class RoutinePreviewScreen extends StatelessWidget {
  final String routineId;

  const RoutinePreviewScreen({super.key, required this.routineId});

  /// Show [CupertinoActionSheet]
  void _showWorkoutPreviewActionSheet({required BuildContext context, required RoutineDto routine}) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(color: tealBlueDark);
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _navigateToRoutineEditor(context: context, routine: routine, type: RoutineEditorMode.editing);
            },
            child: Text('Edit', style: textStyle),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _removeRoutine(context: context, routine: routine);
            },
            child: const Text('Delete', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _navigateToRoutineEditor({required BuildContext context, required RoutineDto routine, RoutineEditorMode type = RoutineEditorMode.editing}) {
    Navigator.of(context)
        .push(CupertinoPageRoute(builder: (context) => RoutineEditorScreen(routine: routine, mode: type)));
  }

  void _removeRoutine({required BuildContext context, required RoutineDto routine}) {
    Provider.of<RoutineProvider>(context, listen: false).removeRoutine(id: routine.id);
  }

  /// Convert list of [ExerciseInWorkout] to [ExerciseInWorkoutEditor]
  ProcedureWidget _procedureToWidget({required ProcedureDto procedure, required RoutineDto routine}) {
    return ProcedureWidget(
      procedureDto: procedure,
      otherSuperSetProcedureDto: _whereOtherProcedure(firstProcedure: procedure, routine: routine),
    );
  }

  ProcedureDto? _whereOtherProcedure({required ProcedureDto firstProcedure, required RoutineDto routine}) {
    return routine.procedures.firstWhereOrNull((procedure) =>
        procedure.superSetId == firstProcedure.superSetId && procedure.exercise.id != firstProcedure.exercise.id);
  }

  @override
  Widget build(BuildContext context) {
    final routines = Provider.of<RoutineProvider>(context, listen: true).routines;
    final routineToPreview = routines.firstWhere((item) => item.id == routineId);
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () => _navigateToRoutineEditor(context: context, routine: routineToPreview, type: RoutineEditorMode.routine),
          backgroundColor: tealBlueLight,
          child: const Icon(CupertinoIcons.play_arrow_solid),
        ),
        backgroundColor: tealBlueDark,
        appBar: CupertinoNavigationBar(
          backgroundColor: tealBlueDark,
          trailing: GestureDetector(
              onTap: () => _showWorkoutPreviewActionSheet(context: context, routine: routineToPreview),
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
                      title: Text(routineToPreview.name,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.white.withOpacity(0.8),
                              fontSize: 18)),
                    ),
                    CupertinoListTile(
                      backgroundColor: tealBlueLight,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      title: Text(routineToPreview.notes,
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
                      itemBuilder: (BuildContext context, int index) {
                        // Build the item widget based on the data at the specified index.
                        final procedure = routineToPreview.procedures[index];
                        return _procedureToWidget(procedure: procedure, routine: routineToPreview);
                      },
                      separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 12),
                      itemCount: routineToPreview.procedures.length),
                ),
              ],
            ),
          ),
        ));
  }
}

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/screens/routine_editor_screen.dart';
import 'package:tracker_app/widgets/routine/preview/procedure_widget.dart';

import '../app_constants.dart';
import '../dtos/procedure_dto.dart';
import '../dtos/routine_log_dto.dart';
import '../providers/routine_log_provider.dart';

class RoutineLogPreviewScreen extends StatelessWidget {
  final String routineLogId;

  const RoutineLogPreviewScreen({super.key, required this.routineLogId});

  /// Show [CupertinoActionSheet]
  void _showWorkoutPreviewActionSheet({required BuildContext context, required RoutineLogDto logDto}) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(color: tealBlueDark);
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _navigateToRoutineEditor(context: context, logDto: logDto);
            },
            child: Text('Edit', style: textStyle),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _removeLog(context: context, logDto: logDto);
            },
            child: const Text('Delete', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _navigateToRoutineEditor(
      {required BuildContext context,
      required RoutineLogDto logDto}) async {
    Navigator.of(context).push(CupertinoPageRoute(
        builder: (context) => RoutineEditorScreen(routineDto: logDto, mode: RoutineEditorMode.editing, type: RoutineEditingType.log)));
  }

  void _removeLog({required BuildContext context, required RoutineLogDto logDto}) {
    Provider.of<RoutineLogProvider>(context, listen: false).removeLog(id: logDto.id);
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
    final logDto = Provider.of<RoutineLogProvider>(context, listen: true).whereRoutineLog(id: routineLogId);

    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () => _navigateToRoutineEditor(context: context, logDto: logDto),
          backgroundColor: tealBlueLighter,
          child: const Icon(Icons.edit),
        ),
        backgroundColor: tealBlueDark,
        appBar: CupertinoNavigationBar(
          backgroundColor: tealBlueDark,
          trailing: GestureDetector(
              onTap: () => _showWorkoutPreviewActionSheet(context: context, logDto: logDto),
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
                Text(logDto.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 18)),
                const SizedBox(height: 8),
                Text(logDto.notes,
                    style: TextStyle(
                      color: CupertinoColors.white.withOpacity(0.8),
                      fontSize: 14,
                    )),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                      itemBuilder: (BuildContext context, int index) =>
                          _procedureToWidget(procedure: logDto.procedures[index], otherProcedures: logDto.procedures),
                      separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 12),
                      itemCount: logDto.procedures.length),
                ),
              ],
            ),
          ),
        ));
  }
}

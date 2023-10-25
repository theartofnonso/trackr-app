import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/dtos/routine_dto.dart';
import 'package:tracker_app/screens/routine_preview_screen.dart';

import '../dtos/procedure_dto.dart';
import '../providers/routine_log_provider.dart';
import '../providers/routine_provider.dart';
import '../widgets/helper_widgets/dialog_helper.dart';
import 'routine_editor_screen.dart';

void _navigateToRoutineEditor(
    {required BuildContext context, RoutineDto? routineDto, RoutineEditorMode mode = RoutineEditorMode.editing}) async {
  await Navigator.of(context).push(CupertinoPageRoute(
      builder: (context) =>
          RoutineEditorScreen(routineDto: routineDto, mode: mode, type: RoutineEditingType.template)));
  if (context.mounted) {
    showMinimisedRoutineBanner(context);
  }
}

class RoutinesScreen extends StatelessWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<RoutineProvider, RoutineLogProvider>(builder: (_, routineProvider, routineLogProvider, __) {
      final cachedRoutineLog = routineLogProvider.cachedLogDto;
      return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () => _navigateToRoutineEditor(context: context),
            backgroundColor: tealBlueLighter,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: const Icon(Icons.add),
          ),
          body: SafeArea(
              child: routineProvider.routines.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(children: [
                        Expanded(
                          child: ListView.separated(
                              itemBuilder: (BuildContext context, int index) => _RoutineWidget(
                                  routineDto: routineProvider.routines[index],
                                  canStartRoutine: cachedRoutineLog == null),
                              separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 12),
                              itemCount: routineProvider.routines.length),
                        )
                      ]))
                  : const Center(child: _RoutinesEmptyState())));
    });
  }
}

class _RoutineWidget extends StatelessWidget {
  final RoutineDto routineDto;
  final bool canStartRoutine;

  const _RoutineWidget({required this.routineDto, required this.canStartRoutine});

  /// Show [CupertinoActionSheet]
  void _showWorkoutActionSheet({required BuildContext context}) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(color: tealBlueDark);

    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(
          routineDto.name,
          style: textStyle?.copyWith(color: tealBlueLight.withOpacity(0.6)),
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _navigateToRoutineEditor(context: context, routineDto: routineDto);
            },
            child: Text(
              'Edit',
              style: textStyle,
            ),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              Provider.of<RoutineProvider>(context, listen: false).removeRoutine(id: routineDto.id);
            },
            child: const Text(
              'Remove',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToRoutinePreview({required BuildContext context}) async {
    final routine = await Navigator.of(context).push(CupertinoPageRoute(
            builder: (context) => RoutinePreviewScreen(routineId: routineDto.id)))
        as Map<String, String>?;
    if (routine != null) {
      final id = routine["id"] ?? "";
      if (id.isNotEmpty) {
        if (context.mounted) {
          Provider.of<RoutineProvider>(context, listen: false).removeRoutine(id: id);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CupertinoListTile(
            backgroundColorActivated: tealBlueLight,
            leading: canStartRoutine
                ? GestureDetector(
                    onTap: () {
                      _navigateToRoutineEditor(
                          context: context, routineDto: routineDto, mode: RoutineEditorMode.routine);
                    },
                    child: const Icon(CupertinoIcons.play_arrow_solid, color: CupertinoColors.white))
                : null,
            title: Text(routineDto.name, style: Theme.of(context).textTheme.labelLarge),
            subtitle: Row(children: [
              const Icon(
                CupertinoIcons.number,
                color: CupertinoColors.white,
                size: 12,
              ),
              Text("${routineDto.procedures.length} exercises",
                  style: TextStyle(color: CupertinoColors.white.withOpacity(0.8), fontWeight: FontWeight.w500)),
            ]),
            trailing: GestureDetector(
                onTap: () => _showWorkoutActionSheet(context: context),
                child: const Icon(
                  CupertinoIcons.ellipsis,
                  color: CupertinoColors.white,
                ))),
        const SizedBox(height: 8),
        ..._proceduresToWidgets(context: context, procedures: routineDto.procedures),
        routineDto.procedures.length > 3
            ? Text(_footerLabel(),
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(fontSize: 14, color: CupertinoColors.white.withOpacity(0.6)))
            : const SizedBox.shrink()
      ],
    );
  }

  String _footerLabel() {
    final exercisesPlural = routineDto.procedures.length - 3 > 1 ? "exercises" : "exercise";
    return "Plus ${routineDto.procedures.length - 3} more $exercisesPlural";
  }

  List<Widget> _proceduresToWidgets({required BuildContext context, required List<ProcedureDto> procedures}) {
    return procedures
        .take(3)
        .map((procedure) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: CupertinoListTile(
                  onTap: () => _navigateToRoutinePreview(context: context),
                  backgroundColor: tealBlueLight,
                  backgroundColorActivated: tealBlueLight,
                  title: Text(procedure.exercise.name,
                      style: const TextStyle(color: CupertinoColors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                  trailing: Text("${procedure.sets.length} sets", style: Theme.of(context).textTheme.labelMedium)),
            ))
        .toList();
  }
}

class _RoutinesEmptyState extends StatelessWidget {
  const _RoutinesEmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Create workouts ahead of gym time", style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

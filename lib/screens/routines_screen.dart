import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/screens/routine_preview_screen.dart';

import '../dtos/procedure_dto.dart';
import '../models/Routine.dart';
import '../providers/routine_provider.dart';
import 'routine_editor_screen.dart';

void _navigateToRoutineEditor({required BuildContext context, Routine? routine}) {
  Navigator.of(context).push(CupertinoPageRoute(builder: (context) => RoutineEditorScreen(routine: routine)));
}

class RoutinesScreen extends StatelessWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final routines = Provider.of<RoutineProvider>(context, listen: true).routines;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.transparent,
        trailing: GestureDetector(
            onTap: () => {},
            child: const Icon(
              CupertinoIcons.plus_app,
              size: 24,
              color: CupertinoColors.white,
            )),
      ),
      child: SafeArea(
        child: routines.isNotEmpty ? _RoutineList(routines: routines) : const Center(child: _RoutinesEmptyState()),
      ),
    );
  }
}

class _RoutineList extends StatelessWidget {
  final List<Routine> routines;

  const _RoutineList({required this.routines});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(children: [
          Expanded(
            child: ListView.separated(
                itemBuilder: (BuildContext context, int index) => _RoutineWidget(routine: routines[index]),
                separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 12),
                itemCount: routines.length),
          )
        ]));
  }
}

class _RoutineWidget extends StatelessWidget {
  final Routine routine;

  const _RoutineWidget({required this.routine});

  /// Show [CupertinoActionSheet]
  void _showWorkoutActionSheet({required BuildContext context}) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(color: tealBlueDark);

    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(
          routine.name,
          style: textStyle?.copyWith(color: tealBlueLight.withOpacity(0.6)),
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _navigateToRoutineEditor(context: context, routine: routine);
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
              Provider.of<RoutineProvider>(context, listen: false).removeRoutine(id: routine.id);
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
    Navigator.of(context).push(CupertinoPageRoute(builder: (context) => RoutinePreviewScreen(routineId: routine.id)));
  }

  @override
  Widget build(BuildContext context) {
    final procedures =
        routine.procedures.map((procedureJson) => ProcedureDto.fromJson(json.decode(procedureJson), context)).toList();
    return GestureDetector(
      onTap: () => _navigateToRoutinePreview(context: context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CupertinoListTile(
              onTap: () => _navigateToRoutinePreview(context: context),
              leading:
                  GestureDetector(child: const Icon(CupertinoIcons.play_arrow_solid, color: CupertinoColors.white)),
              title: Text(routine.name, style: Theme.of(context).textTheme.labelLarge),
              subtitle: Row(children: [
                const Icon(
                  CupertinoIcons.number,
                  color: CupertinoColors.white,
                  size: 12,
                ),
                Text("${routine.procedures.length} exercises",
                    style: TextStyle(color: CupertinoColors.white.withOpacity(0.8), fontWeight: FontWeight.w500)),
              ]),
              trailing: GestureDetector(
                  onTap: () => _showWorkoutActionSheet(context: context),
                  child: const Icon(
                    CupertinoIcons.ellipsis,
                    color: CupertinoColors.white,
                  ))),
          const SizedBox(height: 8),
          ..._proceduresToWidgets(context: context, procedures: procedures),
          routine.procedures.length > 3
              ? Text(_footerLabel(), style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 14, color: CupertinoColors.white.withOpacity(0.6)))
              : const SizedBox.shrink()
        ],
      ),
    );
  }

  String _footerLabel() {
    final exercisesPlural = routine.procedures.length - 3 > 1 ? "exercises" : "exercise";
    return "See ${routine.procedures.length - 3} more $exercisesPlural";
  }

  List<Widget> _proceduresToWidgets({required BuildContext context, required List<ProcedureDto> procedures}) {
    return procedures
        .take(3)
        .map((procedure) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: CupertinoListTile(
                  backgroundColor: tealBlueLight,
                  title:
                      Text(procedure.exercise.name, style: const TextStyle(color: CupertinoColors.white, fontSize: 14)),
                  trailing: Text("${procedure.sets.length} sets", style: Theme.of(context).textTheme.labelMedium)),
            ))
        .toList();
  }
}

class _RoutinesEmptyState extends StatelessWidget {
  const _RoutinesEmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Create workouts ahead of gym time", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: CupertinoButton(
              color: tealBlueLight,
              onPressed: () => _navigateToRoutineEditor(context: context),
              child: Text(
                "Create Workout",
                style: Theme.of(context).textTheme.labelLarge,
              )),
        )
      ],
    );
  }
}

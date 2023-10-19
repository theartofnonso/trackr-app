import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/screens/routine_preview_screen.dart';

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
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: routines.isNotEmpty
              ? _RoutineList(routines: routines)
              : const Center(child: _RoutinesEmptyState()),
        ),
      ),
    );
  }
}

class _RoutineList extends StatelessWidget {
  final List<Routine> routines;

  const _RoutineList({required this.routines});

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      CupertinoListSection.insetGrouped(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        backgroundColor: Colors.transparent,
        header: CupertinoListTile(
          padding: EdgeInsets.zero,
          title: Text("Workouts", style: Theme.of(context).textTheme.titleLarge),
          trailing: GestureDetector(
              onTap: () => _navigateToRoutineEditor(context: context),
              child: const Icon(
                CupertinoIcons.plus,
                size: 24,
                color: CupertinoColors.white,
              )),
        ),
        children: [...routines.map((routine) => _RoutineWidget(routine: routine)).toList()],
      ),
    ]);
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
              _removeRoutine(context: context);
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

  void _removeRoutine({required BuildContext context}) {
    Provider.of<RoutineProvider>(context, listen: false).removeRoutine(id: routine.id);
  }

  void _navigateToRoutinePreview({required BuildContext context}) async {
    Navigator.of(context)
        .push(CupertinoPageRoute(builder: (context) => RoutinePreviewScreen(routineId: routine.id)));
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile.notched(
        onTap: () => _navigateToRoutinePreview(context: context),
        backgroundColor: tealBlueLight,
        backgroundColorActivated: tealBlueLighter,
        title: Text(
          routine.name,
          style: const TextStyle(color: CupertinoColors.white),
        ),
        subtitle: Text("${routine.procedures.length} exercises", style: const TextStyle(color: CupertinoColors.white)),
        trailing: GestureDetector(
            onTap: () => _showWorkoutActionSheet(context: context),
            child: const Padding(
              padding: EdgeInsets.only(right: 1.0),
              child: Icon(
                CupertinoIcons.ellipsis,
                color: CupertinoColors.white,
              ),
            )));
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

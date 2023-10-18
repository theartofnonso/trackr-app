import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/screens/routine_preview_screen.dart';

import '../dtos/routine_dto.dart';
import '../providers/routine_provider.dart';
import 'routine_editor_screen.dart';

void _navigateToWorkoutEditorScreen({required BuildContext context, RoutineDto? routineDto}) {
  Navigator.of(context).push(CupertinoPageRoute(builder: (context) => RoutineEditorScreen(routine: routineDto)));
}

class ActivityOverviewScreen extends StatelessWidget {
  const ActivityOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workouts = Provider.of<RoutineProvider>(context, listen: true).routines;

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: workouts.isNotEmpty
              ? _ListOfWorkouts(workouts: workouts)
              : const Center(child: _WorkoutsEmptyState()),
        ),
      ),
    );
  }
}

class _ListOfWorkouts extends StatelessWidget {
  final List<RoutineDto> workouts;

  const _ListOfWorkouts({required this.workouts});

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
              onTap: () => _navigateToWorkoutEditorScreen(context: context),
              child: const Icon(
                CupertinoIcons.plus,
                size: 24,
                color: CupertinoColors.white,
              )),
        ),
        children: [...workouts.map((workout) => _RoutineWidget(routineDto: workout)).toList()],
      ),
    ]);
  }
}

class _RoutineWidget extends StatelessWidget {
  final RoutineDto routineDto;

  const _RoutineWidget({required this.routineDto});

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
              _navigateToWorkoutEditorScreen(context: context, routineDto: routineDto);
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
              _removeWorkout(context: context);
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

  void _removeWorkout({required BuildContext context}) {
    Provider.of<RoutineProvider>(context, listen: false).removeRoutine(id: routineDto.id);
  }

  void _navigateToWorkoutPreviewScreen({required BuildContext context}) async {
    Navigator.of(context)
        .push(CupertinoPageRoute(builder: (context) => RoutinePreviewScreen(routineId: routineDto.id)));
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile.notched(
        onTap: () => _navigateToWorkoutPreviewScreen(context: context),
        backgroundColor: tealBlueLight,
        backgroundColorActivated: tealBlueLighter,
        title: Text(
          routineDto.name,
          style: const TextStyle(color: CupertinoColors.white),
        ),
        subtitle: Text("${routineDto.procedures.length} exercises", style: const TextStyle(color: CupertinoColors.white)),
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

class _WorkoutsEmptyState extends StatelessWidget {

  const _WorkoutsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Start tracking your performance", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: CupertinoButton(
              color: tealBlueLight,
              onPressed: () => _navigateToWorkoutEditorScreen(context: context),
              child: Text(
                "Create Workout",
                style: Theme.of(context).textTheme.labelLarge,
              )),
        )
      ],
    );
  }
}

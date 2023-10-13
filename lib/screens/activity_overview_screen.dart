import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/screens/workout_preview_screen.dart';

import '../dtos/workout_dto.dart';
import '../providers/workout_provider.dart';
import 'workout_editor_screen.dart';

void _showWorkoutEditorScreen({required BuildContext context, WorkoutDto? workoutDto}) async {
  Navigator.of(context).push(CupertinoPageRoute(builder: (context) => WorkoutEditorScreen(workoutDto: workoutDto)));
}

class ActivityOverviewScreen extends StatelessWidget {
  const ActivityOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workouts = Provider.of<WorkoutProvider>(context, listen: true).workouts;

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: workouts.isNotEmpty
              ? _ListOfWorkouts(workouts: workouts)
              : Center(child: _WorkoutsEmptyState(onPressed: () => _showWorkoutEditorScreen(context: context))),
        ),
      ),
    );
  }
}

class _ListOfWorkouts extends StatelessWidget {
  final List<WorkoutDto> workouts;

  const _ListOfWorkouts({required this.workouts});

  void _removeWorkout({required BuildContext context, required String workoutId}) {
    Provider.of<WorkoutProvider>(context, listen: false).removeWorkout(id: workoutId);
  }

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
              onTap: () => _showWorkoutEditorScreen(context: context),
              child: const Icon(
                CupertinoIcons.plus,
                size: 24,
                color: CupertinoColors.white,
              )),
        ),
        children: [
          ...workouts
              .map((workout) => _WorkoutListItem(
                  workoutDto: workout, onRemoveWorkout: () => _removeWorkout(context: context, workoutId: workout.id)))
              .toList()
        ],
      ),
    ]);
  }
}

class _WorkoutListItem extends StatelessWidget {
  final WorkoutDto workoutDto;
  final void Function() onRemoveWorkout;

  const _WorkoutListItem({required this.workoutDto, required this.onRemoveWorkout});

  /// Show [CupertinoActionSheet]
  void _showWorkoutActionSheet({required BuildContext context}) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              onRemoveWorkout();
            },
            child: Text(
              'Remove ${workoutDto.name}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showWorkoutPreviewScreen({required BuildContext context, required WorkoutDto workoutDto}) async {
    Navigator.of(context).push(CupertinoPageRoute(builder: (context) => WorkoutPreviewScreen(workoutDto: workoutDto)));
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile.notched(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        onTap: () => _showWorkoutPreviewScreen(context: context, workoutDto: workoutDto),
        backgroundColor: tealBlueLight,
        title: Text(
          workoutDto.name,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        subtitle: Text("${workoutDto.exercises.length} exercises", style: Theme.of(context).textTheme.bodySmall),
        leading: CircleAvatar(
          backgroundColor: CupertinoColors.activeBlue,
          child: Text(
            workoutDto.name.substring(0, 1),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
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
  final Function() onPressed;

  const _WorkoutsEmptyState({required this.onPressed});

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
              onPressed: onPressed,
              child: Text(
                "Create Workout",
                style: Theme.of(context).textTheme.labelLarge,
              )),
        )
      ],
    );
  }
}

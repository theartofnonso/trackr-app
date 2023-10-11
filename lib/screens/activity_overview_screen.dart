import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';

import '../dtos/workout_dto.dart';
import '../providers/workout_provider.dart';
import 'new_workout_screen.dart';

void _showNewWorkoutScreen({required BuildContext context, WorkoutDto? workoutDto}) async {
  Navigator.of(context).push(
      CupertinoPageRoute(builder: (context) => NewWorkoutScreen(workoutDto: workoutDto)));
}

class ActivityOverviewScreen extends StatelessWidget {
  const ActivityOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workouts =
        Provider.of<WorkoutProvider>(context, listen: true).workouts;

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: workouts.isNotEmpty
              ? _ListOfWorkouts(workouts: workouts, onTap: () => _showNewWorkoutScreen(context: context),)
              : Center(
                  child: _WorkoutsEmptyState(
                      onPressed: () => _showNewWorkoutScreen(context: context))),
        ),
      ),
    );
  }
}

class _ListOfWorkouts extends StatelessWidget {
  final List<WorkoutDto> workouts;
  final void Function()? onTap;

  const _ListOfWorkouts({required this.workouts, this.onTap});

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
          title: const Text("Workouts", style: TextStyle(fontSize: 18),),
          trailing: GestureDetector(
              onTap: onTap,
              child: const Icon(
                CupertinoIcons.plus,
                size: 24,
              )),
        ),
        children:  [
          ...workouts.map((workout) => _WorkoutListItem(workoutDto: workout, onRemoveWorkout: () => _removeWorkout(context: context, workoutId: workout.id))).toList()
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
            child: Text('Remove ${workoutDto.name}'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile.notched(
      onTap: () => _showNewWorkoutScreen(context: context, workoutDto: workoutDto),
        backgroundColor: tealBlueLight,
        title: Text(workoutDto.name),
        subtitle: Text("${workoutDto.exercises.length} exercises", style: TextStyle(color: CupertinoColors.white.withOpacity(0.7)),),
        leading: CircleAvatar(
          backgroundColor: CupertinoColors.activeBlue,
          child: Text(
            workoutDto.name.substring(0, 1),
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: CupertinoColors.white),
          ),
        ),
        trailing: GestureDetector(
          onTap: () => _showWorkoutActionSheet(context: context),
            child: const Padding(
              padding: EdgeInsets.only(right: 1.0),
              child: Icon(CupertinoIcons.ellipsis),
            ))
    );
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
        const Text("Start tracking your performance"),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: CupertinoButton(
              color: tealBlueLight,
              onPressed: onPressed,
              child: const Text(
                "Create Workout",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
        )
      ],
    );
  }
}

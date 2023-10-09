import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/screens/new_workout_screen.dart';

import '../dtos/workout_dto.dart';
import '../providers/workout_provider.dart';

class ActivityOverviewScreen extends StatelessWidget {
  const ActivityOverviewScreen({super.key});

  void _showNewWorkoutScreen(BuildContext context) async {
    Navigator.of(context).push(
        CupertinoPageRoute(builder: (context) => const NewWorkoutScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final workouts =
        Provider.of<WorkoutProvider>(context, listen: true).workouts;

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: !workouts.isNotEmpty
              ? _ListOfWorkouts(workouts: workouts, onTap: () => _showNewWorkoutScreen(context),)
              : Center(
                  child: _WorkoutsEmptyState(
                      onPressed: () => _showNewWorkoutScreen(context))),
        ),
      ),
    );
  }
}

class _ListOfWorkouts extends StatelessWidget {
  final List<WorkoutDto> workouts;
  final void Function()? onTap;

  const _ListOfWorkouts({super.key, required this.workouts, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      CupertinoListSection.insetGrouped(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        backgroundColor: Colors.transparent,
        header: CupertinoListTile(
          padding: EdgeInsets.zero,
          title: Text("Workouts", style: TextStyle(fontSize: 18),),
          trailing: GestureDetector(
              onTap: onTap,
              child: const Icon(
                CupertinoIcons.plus,
                size: 24,
              )),
        ),
        children:  [
          CupertinoListTile.notched(
              backgroundColor: Color.fromRGBO(25, 28, 36, 1),
              title: Text("Push Day"),
              subtitle: Text("10 exercises", style: TextStyle(color: CupertinoColors.white.withOpacity(0.7)),),
              leading: CircleAvatar(
                backgroundColor: CupertinoColors.activeBlue,
                child: Text(
                  "P",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: CupertinoColors.white),
                ),
              ),
              trailing: GestureDetector(
                  child: const Padding(
                    padding: EdgeInsets.only(right: 1.0),
                    child: Icon(CupertinoIcons.ellipsis),
                  ))
          ),
          CupertinoListTile.notched(
              backgroundColor: Color.fromRGBO(25, 28, 36, 1),
              title: Text("Pull Day"),
              subtitle: Text("10 exercises", style: TextStyle(color: CupertinoColors.white.withOpacity(0.7)),),
              leading: CircleAvatar(
                backgroundColor: CupertinoColors.activeBlue,
                child: Text(
                  "P",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: CupertinoColors.white),
                ),
              ),
              trailing: GestureDetector(
                  child: const Padding(
                    padding: EdgeInsets.only(right: 1.0),
                    child: Icon(CupertinoIcons.ellipsis),
                  ))
          ),
          CupertinoListTile.notched(
              backgroundColor: Color.fromRGBO(25, 28, 36, 1),
              title: Text("Leg Day"),
              subtitle: Text("8 exercises", style: TextStyle(color: CupertinoColors.white.withOpacity(0.7)),),
              leading: CircleAvatar(
                backgroundColor: CupertinoColors.activeBlue,
                child: Text(
                  "L",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: CupertinoColors.white),
                ),
              ),
              trailing: GestureDetector(
                  child: const Padding(
                    padding: EdgeInsets.only(right: 1.0),
                    child: Icon(CupertinoIcons.ellipsis),
                  ))
          ),
        ],
      ),
    ]);
    return ListView(
        children: workouts
            .map((workout) =>
                CupertinoListTile.notched(title: Text(workout.name)))
            .toList());
  }
}

class _WorkoutsEmptyState extends StatelessWidget {
  final Function() onPressed;

  const _WorkoutsEmptyState({super.key, required this.onPressed});

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

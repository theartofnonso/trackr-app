import 'package:flutter/cupertino.dart';
import 'package:tracker_app/screens/new_workout_screen.dart';

class ActivityOverviewScreen extends StatelessWidget {
  const ActivityOverviewScreen({super.key});

  Future<void> _showNewWorkoutScreen(BuildContext context) async {
    final newWorkout = await Navigator.of(context).push(
        CupertinoPageRoute(builder: (context) => const NewWorkoutScreen()));
    print(newWorkout);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: EdgeInsets.all(5),
            child: Column(
              children: [
                // Calendar(),
                // SizedBox(height: 15,),
                // NotesEditor(),
                CupertinoButton.filled(
                    child: const Text("Create Workout"),
                    onPressed: () => _showNewWorkoutScreen(context))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

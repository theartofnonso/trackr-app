import 'package:flutter/cupertino.dart';
import 'package:tracker_app/screens/exercises_screen.dart';

class ActivityOverviewScreen extends StatelessWidget {
  const ActivityOverviewScreen({super.key});

  Future<void> _showListOfExercises(BuildContext context) async {
    final selectedExercises = await showCupertinoModalPopup(context: context, builder: (BuildContext context) {
        return const ExercisesScreen();
    }, );

    print(selectedExercises);

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
                CupertinoButton.filled(child: const Text("Exercises"), onPressed: () => _showListOfExercises(context))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

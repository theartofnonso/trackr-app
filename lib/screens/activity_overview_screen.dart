import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/screens/calender_widget.dart';
import 'package:tracker_app/screens/exercises_screen.dart';

import 'notes_editor_widgets.dart';

class ActivityOverviewScreen extends StatelessWidget {
  const ActivityOverviewScreen({super.key});

  void _showListOfExercises(BuildContext context) {
    showCupertinoModalPopup(context: context, builder: (BuildContext context) {
        return ExercisesScreen();
    }, );
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

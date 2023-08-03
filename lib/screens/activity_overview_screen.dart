import 'package:flutter/material.dart';
import 'package:tracker_app/screens/calender_widget.dart';

import 'notes_editor_widgets.dart';

class ActivityOverviewScreen extends StatelessWidget {
  const ActivityOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: EdgeInsets.all(5),
            child: Column(
              children: [
                Calendar(),
                SizedBox(height: 15,),
                NotesEditor()
              ],
            ),
          ),
        ),
      ),
    );
  }
}

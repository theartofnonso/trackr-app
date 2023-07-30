import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/providers/datetime_entry_provider.dart';
import 'package:tracker_app/screens/calender_widget.dart';

import 'notes_widgets.dart';

class ActivityOverviewScreen extends StatefulWidget {
  const ActivityOverviewScreen({super.key});

  @override
  State<ActivityOverviewScreen> createState() => _ActivityOverviewScreenState();
}

class _ActivityOverviewScreenState extends State<ActivityOverviewScreen> {

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Column(
            children: [
              Calendar(),
              SizedBox(height: 20,),
              Notes()
            ],
          ),
        ),
      ),
    );
  }

}

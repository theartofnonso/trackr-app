import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/providers/datetime_entry_provider.dart';
import 'package:tracker_app/screens/calender_widget.dart';

class ActivityOverviewScreen extends StatefulWidget {
  const ActivityOverviewScreen({super.key});

  @override
  State<ActivityOverviewScreen> createState() => _ActivityOverviewScreenState();
}

class _ActivityOverviewScreenState extends State<ActivityOverviewScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Consumer<DateTimeEntryProvider>(builder: (_, dateEntryProvider, __) {
            return const Calendar();
          }),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}

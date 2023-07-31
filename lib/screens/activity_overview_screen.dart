import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/providers/datetime_entry_provider.dart';
import 'package:tracker_app/screens/calender_widget.dart';

import 'notes_editor_widgets.dart';

class ActivityOverviewScreen extends StatefulWidget {
  const ActivityOverviewScreen({super.key});

  @override
  State<ActivityOverviewScreen> createState() => _ActivityOverviewScreenState();
}

class _ActivityOverviewScreenState extends State<ActivityOverviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              children: [
                const Calendar(),
                const SizedBox(
                  height: 20,
                ),
                Consumer<DateTimeEntryProvider>(
                    builder: (_, dateTimeEntryProvider, __) {
                  final dateTimeEntry = dateTimeEntryProvider.selectedDateTimeEntry;
                  return dateTimeEntry != null
                      ? NotesEditor(
                          dateTimeEntryProvider: dateTimeEntryProvider,
                          dateTimeEntry: dateTimeEntry)
                      : const SizedBox.shrink();
                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}

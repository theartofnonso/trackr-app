import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/providers/activity_provider.dart';
import 'package:tracker_app/screens/add_activity_screen.dart';
import 'package:tracker_app/widgets/buttons/button_wrapper_widget.dart';

import '../widgets/buttons/gradient_button_widget.dart';
import '../widgets/buttons/text_button_widget.dart';

class ActivitySelectionScreen extends StatefulWidget {
  const ActivitySelectionScreen({super.key});

  @override
  State<ActivitySelectionScreen> createState() => _ActivitySelectionScreen();
}

class _ActivitySelectionScreen extends State<ActivitySelectionScreen> {

  void _goBack({Activity? activity}) {
    Navigator.of(context).pop(activity);
  }

  void _navigateToAddNewActivityScreen() async {
    final selectedActivity = await showDialog(
        context: context,
        builder: ((context) {
          return const AddActivityScreen();
        }));
    if (mounted) {
      _goBack(activity: selectedActivity);
    }
  }

  List<CTextButtonWidget> _activitiesToButtons(
      {required List<Activity> activities}) {
    return activities
        .map((activity) => CTextButtonWidget(
              onPressed: () =>
                  _goBack(activity: activity),
              label: activity.name,
              textStyle: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                CButtonWrapperWidget(
                    onPressed: _goBack,
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ))
              ],
            ),
            Expanded(
              child: Consumer<ActivityProvider>(
                  builder: (_, activityProvider, __) {
                return ListView(
                  children: [
                    ..._activitiesToButtons(
                        activities: activityProvider.activities)
                  ],
                );
              }),
            ),
            GradientButton(
              onPressed: _navigateToAddNewActivityScreen,
              label: "Track new activity",
            )
          ],
        ),
      ),
    );
  }
}

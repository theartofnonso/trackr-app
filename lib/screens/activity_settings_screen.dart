import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/providers/activity_provider.dart';
import 'package:tracker_app/screens/add_activity_screen.dart';
import 'package:tracker_app/widgets/buttons/button_wrapper_widget.dart';

import '../utils/navigator_utils.dart';
import '../widgets/buttons/text_button_widget.dart';

class ActivitySettingsScreen extends StatelessWidget {
  final Activity activity;

  const ActivitySettingsScreen({super.key, required this.activity});

  void _navigateToActivitySelectionScreen({required BuildContext context}) {
    Navigator.of(context).pop(activity);
  }

  void _navigateToAddNewActivityScreen({required BuildContext context}) {
    final route = createNewRouteFadeTransition(AddActivityScreen(
      activity: activity,
    ));
    Navigator.of(context).push(route);
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
                    onPressed: () =>
                        _navigateToActivitySelectionScreen(context: context),
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
                    CTextButtonWidget(
                      onPressed: () =>
                          _navigateToAddNewActivityScreen(context: context),
                      label: "edit",
                      style: GoogleFonts.inconsolata(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ),
                    CTextButtonWidget(
                      onPressed: () {},
                      label: "delete",
                      style: GoogleFonts.inconsolata(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey),
                    )
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

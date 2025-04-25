import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/utils/navigation_utils.dart';
import 'package:tracker_app/widgets/empty_states/no_list_empty_state.dart';

import '../../controllers/exercise_and_routine_controller.dart';
import '../../controllers/routine_user_controller.dart';
import '../../utils/general_utils.dart';

class NotificationsScreenScreen extends StatelessWidget {
  static const routeName = '/notifications_screen';

  const NotificationsScreenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final exerciseAndRoutineController = Provider.of<ExerciseAndRoutineController>(context, listen: true);

    final routineUserController = Provider.of<RoutineUserController>(context, listen: true);

    final user = routineUserController.user;

    final routineTemplates = exerciseAndRoutineController.templates;

    final routinePlans = exerciseAndRoutineController.plans;

    final hasPendingActions = routineTemplates.isEmpty || routinePlans.isEmpty || user == null;

    final deviceOS = Platform.isIOS ? "Apple Health" : "Google Health";

    return Scaffold(
      appBar: AppBar(
        title: Text("TRKR Notifications".toUpperCase()),
        leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.squareXmark, size: 28), onPressed: Navigator.of(context).pop),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: themeGradient(context: context),
        ),
        child: SafeArea(
          bottom: false,
          //  minimum: const EdgeInsets.symmetric(horizontal: 20),
          child: hasPendingActions
              ? Column(
                  children: [
                    if (routineTemplates.isEmpty)
                      ListTile(
                        onTap: () => navigateToRoutineHome(context: context),
                        leading: FaIcon(
                          FontAwesomeIcons.solidBell,
                          size: 20,
                        ),
                        title: Text("Create A Workout Template"),
                        subtitle: Text("Design your first routine"),
                        trailing: FaIcon(
                          FontAwesomeIcons.chevronRight,
                          size: 12,
                          color: isDarkMode ? Colors.white70 : Colors.grey.shade400,
                        ),
                      ),
                    if (routinePlans.isEmpty)
                      ListTile(
                        onTap: () => navigateToRoutineHome(context: context),
                        leading: FaIcon(
                          FontAwesomeIcons.solidBell,
                          size: 20,
                        ),
                        title: Text("Create A Workout Plan"),
                        subtitle: Text("Organise your workouts into a plan"),
                        trailing: FaIcon(
                          FontAwesomeIcons.chevronRight,
                          size: 12,
                          color: isDarkMode ? Colors.white70 : Colors.grey.shade400,
                        ),
                      ),
                    ListTile(
                      leading: FaIcon(
                        FontAwesomeIcons.solidBell,
                        size: 20,
                      ),
                      title: Text("Sync with $deviceOS"),
                      subtitle: Text("Connect to improve your training"),
                      trailing: FaIcon(
                        FontAwesomeIcons.chevronRight,
                        size: 12,
                        color: isDarkMode ? Colors.white70 : Colors.grey.shade400,
                      ),
                    ),
                    if (user == null)
                    ListTile(
                      onTap: () => navigateToProfile(context: context),
                      title: Text("Set up your profile"),
                      leading: FaIcon(
                        FontAwesomeIcons.solidBell,
                        size: 20,
                      ),
                      subtitle: Text("Visit settings to create a profile"),
                      trailing: FaIcon(
                        FontAwesomeIcons.chevronRight,
                        size: 12,
                        color: isDarkMode ? Colors.white70 : Colors.grey.shade400,
                      ),
                    ),
                  ],
                )
              : Center(
                  child: NoListEmptyState(
                      message:
                          "Hurray! You’re all caught up with your notifications. Check back later for updates or new tasks!")),
        ),
      ),
    );
  }
}

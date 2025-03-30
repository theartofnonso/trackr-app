import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/widgets/empty_states/no_list_empty_state.dart';

import '../../controllers/exercise_and_routine_controller.dart';
import '../../controllers/routine_user_controller.dart';
import '../../utils/general_utils.dart';
import '../../widgets/list_tile.dart';

class OnboardingChecklistNotificationsScreenScreen extends StatelessWidget {
  static const routeName = '/onboarding_checklist_screen';

  const OnboardingChecklistNotificationsScreenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final exerciseAndRoutineController = Provider.of<ExerciseAndRoutineController>(context, listen: true);

    final routineUserController = Provider.of<RoutineUserController>(context, listen: true);

    final user = routineUserController.user;

    final routineLogs = exerciseAndRoutineController.logs;

    final routineTemplates = exerciseAndRoutineController.templates;

    final hasPendingActions = routineTemplates.isEmpty || routineLogs.isEmpty || user == null;

    return Scaffold(
      appBar: AppBar(
        title: Text("TRKR Notificatons".toUpperCase()),
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
          minimum: const EdgeInsets.all(10.0),
          child: hasPendingActions
              ? Column(
                  spacing: 10,
                  children: [
                    if (routineTemplates.isEmpty)
                      ThemeListTile(
                        child: ListTile(
                          title: Text("Create A Workout Template"),
                          leading: Image.asset(
                            'icons/dumbbells.png',
                            fit: BoxFit.contain,
                            color: isDarkMode ? Colors.white : Colors.black,
                            height: 24, // Adjust the height as needed
                          ),
                          subtitle: Text("Design your first routine"),
                          trailing: FaIcon(
                            FontAwesomeIcons.solidBell,
                            size: 18,
                          ),
                        ),
                      ),
                    if (routineLogs.isEmpty)
                      ThemeListTile(
                        child: ListTile(
                          title: Text("Log A Workout Session"),
                          leading: Image.asset(
                            'icons/dumbbells.png',
                            fit: BoxFit.contain,
                            color: isDarkMode ? Colors.white : Colors.black,
                            height: 24, // Adjust the height as needed
                          ),
                          subtitle: Text("Start your fitness journey with a session"),
                          trailing: FaIcon(
                            FontAwesomeIcons.solidBell,
                            size: 18,
                          ),
                        ),
                      ),
                    if (user == null)
                      ThemeListTile(
                        child: ListTile(
                          title: Text("Set up your profile"),
                          leading: FaIcon(FontAwesomeIcons.personWalking),
                          subtitle: Text("Visit settings to create a profile"),
                          trailing: FaIcon(
                            FontAwesomeIcons.solidBell,
                            size: 18,
                          ),
                        ),
                      )
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

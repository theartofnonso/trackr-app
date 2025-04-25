import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sahha_flutter/sahha_flutter.dart';
import 'package:tracker_app/utils/navigation_utils.dart';
import 'package:tracker_app/widgets/empty_states/no_list_empty_state.dart';

import '../../colors.dart';
import '../../controllers/exercise_and_routine_controller.dart';
import '../../controllers/routine_user_controller.dart';
import '../../utils/general_utils.dart';
import '../../widgets/buttons/opacity_button_widget.dart';

class NotificationsScreenScreen extends StatefulWidget {
  static const routeName = '/notifications_screen';

  const NotificationsScreenScreen({super.key});

  @override
  State<NotificationsScreenScreen> createState() => _NotificationsScreenScreenState();
}

class _NotificationsScreenScreenState extends State<NotificationsScreenScreen> {
  SahhaSensorStatus _sensorStatus = SahhaSensorStatus.unavailable;

  final _sensors = [
    SahhaSensor.steps,
    SahhaSensor.sleep,
    SahhaSensor.exercise,
    SahhaSensor.heart_rate_variability_rmssd,
    SahhaSensor.heart_rate_variability_sdnn,
    SahhaSensor.resting_heart_rate
  ];

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final exerciseAndRoutineController = Provider.of<ExerciseAndRoutineController>(context, listen: true);

    final routineUserController = Provider.of<RoutineUserController>(context, listen: true);

    final user = routineUserController.user;

    final routineTemplates = exerciseAndRoutineController.templates;

    final routinePlans = exerciseAndRoutineController.plans;

    final hasPendingActions =
        routineTemplates.isEmpty || routinePlans.isEmpty || user == null || _sensorStatus == SahhaSensorStatus.pending;

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
                    if (_sensorStatus == SahhaSensorStatus.pending)
                      ListTile(
                        onTap: _enableSahhaSensors,
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

  void _getSahhaSensorStatus() {
    // Get status of `steps` and `sleep` sensors
    SahhaFlutter.getSensorStatus(_sensors).then((value) {

      setState(() {
        _sensorStatus = value;
      });
      if (_sensorStatus == SahhaSensorStatus.pending) {
        // Sensors are NOT enabled and ready - Show your custom UI before asking for user permission
      } else if (_sensorStatus == SahhaSensorStatus.enabled) {
        // Sensors are enabled and ready
      } else {
        // Sensors are disabled or unavailable
      }
    }).catchError((error, stackTrace) {
      debugPrint(error.toString());
    });
  }

  void _enableSahhaSensors() {
    navigateWithSlideTransition(
        context: context,
        child: _SahhaSensorsRequestScreen(onPress: () {
          SahhaFlutter.enableSensors(_sensors).then((value) {
            setState(() {
              _sensorStatus = value;
            });
            if (_sensorStatus == SahhaSensorStatus.enabled) {
              // Sensors are enabled and ready
            } else {
              // Sensors are disabled or unavailable
            }
          }).catchError((error, stackTrace) {
            debugPrint(error.toString());
          });
        }));
  }

  @override
  void initState() {
    super.initState();
    _getSahhaSensorStatus();
  }
}

class _SahhaSensorsRequestScreen extends StatelessWidget {
  final VoidCallback onPress;

  const _SahhaSensorsRequestScreen({required this.onPress});

  @override
  Widget build(BuildContext context) {
    final deviceOS = Platform.isIOS ? "Apple Health" : "Google Health";

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.squareXmark, size: 28), onPressed: Navigator.of(context).pop),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: themeGradient(context: context)
        ),
        child: SafeArea(
          minimum: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FaIcon(
                FontAwesomeIcons.personWalking,
                size: 50,
              ),
              const SizedBox(height: 50),
              Text(
                "Connect to $deviceOS",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              Text(
                "We’d like to connect to $deviceOS to better understand your health and provide a more personalized training experience.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26.0),
                child: SizedBox(
                    height: 45,
                    width: double.infinity,
                    child: OpacityButtonWidget(
                      label: "Connect for better training",
                      buttonColor: vibrantGreen,
                      onPressed: onPress,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

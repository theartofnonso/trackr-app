import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sahha_flutter/sahha_flutter.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/screens/overview_screen.dart';
import 'package:tracker_app/screens/notifications/notifications_screen.dart';
import 'package:tracker_app/utils/navigation_utils.dart';

import '../controllers/exercise_and_routine_controller.dart';
import '../utils/general_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    final exerciseAndRoutineController = Provider.of<ExerciseAndRoutineController>(context, listen: true);

    final routineLogs = exerciseAndRoutineController.logs;

    final routineTemplates = exerciseAndRoutineController.templates;

    final hasPendingActions =
        routineTemplates.isEmpty || routineLogs.isEmpty || _sensorStatus == SahhaSensorStatus.pending;

    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
          onPressed: _navigateToNotificationHome,
          icon: Badge(
              smallSize: 8,
              backgroundColor: hasPendingActions ? vibrantGreen : Colors.transparent,
              child: FaIcon(FontAwesomeIcons.solidBell)),
        ),
        IconButton(
          onPressed: () => navigateToSettings(context: context),
          icon: FaIcon(FontAwesomeIcons.gear),
        )
      ]),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: themeGradient(context: context),
        ),
        child: SafeArea(
          minimum: const EdgeInsets.all(10),
          bottom: false,
          child: OverviewScreen(),
        ),
      ),
    );
  }

  void _navigateToNotificationHome() {
    navigateWithSlideTransition(context: context, child: NotificationsScreenScreen());
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

  @override
  void initState() {
    super.initState();
    _getSahhaSensorStatus();
  }
}

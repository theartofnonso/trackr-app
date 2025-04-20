import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/screens/insights/overview_screen.dart';
import 'package:tracker_app/screens/onboarding/onboarding_checklist_notifications_screen.dart';
import 'package:tracker_app/utils/navigation_utils.dart';

import '../controllers/exercise_and_routine_controller.dart';
import '../controllers/routine_user_controller.dart';
import '../utils/date_utils.dart';
import '../utils/general_utils.dart';
import '../widgets/calendar/calendar_navigator.dart';

class HomeTabScreen extends StatefulWidget {
  const HomeTabScreen({super.key});

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> with SingleTickerProviderStateMixin {
  late DateTimeRange _monthDateTimeRange;

  @override
  Widget build(BuildContext context) {
    final exerciseAndRoutineController = Provider.of<ExerciseAndRoutineController>(context, listen: true);

    final routineUserController = Provider.of<RoutineUserController>(context, listen: true);

    final user = routineUserController.user;

    final routineLogs = exerciseAndRoutineController.logs;

    final routineTemplates = exerciseAndRoutineController.templates;

    final hasPendingActions = routineTemplates.isEmpty || routineLogs.isEmpty || user == null;

    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            onPressed: () => navigateToSettings(context: context),
            icon: FaIcon(FontAwesomeIcons.gear, size: 20),
          ),
          title: CalendarNavigator(onMonthChange: _onMonthChange),
          actions: [
            IconButton(
              onPressed: _navigateToNotificationHome,
              icon: Badge(
                  smallSize: 8,
                  backgroundColor: hasPendingActions ? vibrantGreen : Colors.transparent,
                  child: FaIcon(FontAwesomeIcons.solidBell, size: 20)),
            )
          ]),
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: themeGradient(context: context),
        ),
        child: SafeArea(
            minimum: const EdgeInsets.only(top: 10, right: 10, left: 10),
            bottom: false,
            child: SingleChildScrollView(
              child: Column(children: [
                OverviewScreen(dateTimeRange: _monthDateTimeRange),
              ]),
            )),
      ),
    );
  }

  void _navigateToNotificationHome() {
    navigateWithSlideTransition(context: context, child: OnboardingChecklistNotificationsScreenScreen());
  }

  void _onMonthChange(DateTimeRange range) {
    setState(() {
      _monthDateTimeRange = range;
    });
  }

  @override
  void initState() {
    super.initState();
    _monthDateTimeRange = thisMonthDateRange();
  }
}

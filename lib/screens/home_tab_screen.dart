import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/FireStateMachine.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/controllers/analytics_controller.dart';
import 'package:tracker_app/screens/insights/overview_screen.dart';
import 'package:tracker_app/screens/insights/sets_reps_volume_insights_screen.dart';
import 'package:tracker_app/screens/onboarding/onboarding_checklist_notifications_screen.dart';
import 'package:tracker_app/utils/navigation_utils.dart';

import '../colors.dart';
import '../controllers/exercise_and_routine_controller.dart';
import '../utils/general_utils.dart';
import '../controllers/activity_log_controller.dart';
import '../controllers/exercise_and_routine_controller.dart';
import '../utils/date_utils.dart';
import '../widgets/calendar/calendar_navigator.dart';

class HomeTabScreen extends StatefulWidget {
  final ScrollController scrollController;

  const HomeTabScreen({super.key, required this.scrollController});

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> with SingleTickerProviderStateMixin {
  late DateTimeRange _monthDateTimeRange;

  late TabController _tabController;

  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    Provider.of<ExerciseAndRoutineController>(context, listen: true);

    final exerciseAndRoutineController = Provider.of<ExerciseAndRoutineController>(context, listen: true);

    final activityLogController = Provider.of<ActivityLogController>(context, listen: true);

    final routineLogs = exerciseAndRoutineController.logs;

    final routineTemplates = exerciseAndRoutineController.templates;

    final activityLogs = activityLogController.logs;

    final hasPendingActions = routineTemplates.isEmpty || routineLogs.isEmpty || activityLogs.isEmpty;

    return DefaultTabController(
        length: 2,
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                FireWidget(dateTimeRange: _monthDateTimeRange),
                Table(
                  columnWidths: const <int, TableColumnWidth>{
                    0: FixedColumnWidth(50),
                    1: FlexColumnWidth(),
                    2: FixedColumnWidth(50),
                  },
                  children: [
                    TableRow(children: [
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: SizedBox(),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Center(
                          child: CalendarNavigator(
                            onMonthChange: _onMonthChange,
                            enabled: _tabIndex == 0,
                          ),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Center(
                          child: IconButton(
                            onPressed: _navigateToNotificationHome,
                            icon: Badge(
                                smallSize: 8,
                                backgroundColor: hasPendingActions ? vibrantGreen : Colors.transparent,
                                child: FaIcon(FontAwesomeIcons.solidBell, size: 20)),
                          ),
                        ),
                      ),
                    ]),
                  ],
                ),
                TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(
                        child: Text("Overview".toUpperCase(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600))),
                    Tab(
                        child: Text("Muscle Trends".toUpperCase(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)))
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      OverviewScreen(
                        dateTimeRange: _monthDateTimeRange,
                        scrollController: widget.scrollController,
                      ),
                      SetsAndRepsVolumeInsightsScreen(
                        canPop: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void _navigateToNotificationHome() {
    navigateWithSlideTransition(context: context, child: OnboardingChecklistNotificationsScreenScreen());
  }

  void _onMonthChange(DateTimeRange range) {
    AnalyticsController.calendarInteractions(eventAction: "month_change: ${range.toString()}");
    setState(() {
      _monthDateTimeRange = range;
    });
  }

  @override
  void initState() {
    super.initState();
    _monthDateTimeRange = thisMonthDateRange();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _tabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

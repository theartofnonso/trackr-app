import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/FireStateMachine.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/controllers/analytics_controller.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/screens/insights/overview_screen.dart';
import 'package:tracker_app/screens/insights/sets_reps_volume_insights_screen.dart';
import 'package:tracker_app/screens/onboarding/onboarding_checklist_notifications_screen.dart';
import 'package:tracker_app/utils/navigation_utils.dart';

import '../controllers/exercise_and_routine_controller.dart';
import '../controllers/activity_log_controller.dart';
import '../enums/posthog_analytics_event.dart';
import '../utils/date_utils.dart';
import '../utils/dialog_utils.dart';
import '../utils/shareables_utils.dart';
import '../widgets/calendar/calendar.dart';
import '../widgets/calendar/calendar_navigator.dart';
import '../widgets/monitors/log_streak_muscle_trend_monitor.dart';

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
                IconButton(
                  onPressed: () => _showFireBallConfig(context: context),
                  icon: FireWidget(dateTimeRange: _monthDateTimeRange),
                ),
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
                          child: IconButton(
                            onPressed: () => _showShareBottomSheet(context: context),
                            icon: FaIcon(FontAwesomeIcons.arrowUpFromBracket, size: 20),
                          ),
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

  void _showShareBottomSheet({required BuildContext context}) {
    displayBottomSheet(
        context: context,
        child: SafeArea(
          child: Column(children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(Icons.monitor_heart_rounded, size: 18),
              horizontalTitleGap: 6,
              title: Text("Share Streak and Muscle Monitor"),
              onTap: () {
                Navigator.of(context).pop();
                _onShareMonitor(context: context);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(FontAwesomeIcons.calendar, size: 18),
              horizontalTitleGap: 6,
              title: Text("Share Log Calendar"),
              onTap: () {
                Navigator.of(context).pop();
                _onShareCalendar(context: context);
              },
            ),
          ]),
        ));
  }

  void _onShareMonitor({required BuildContext context}) {
    Posthog().capture(eventName: PostHogAnalyticsEvent.shareMonitor.displayName);
    onShare(
        context: context,
        globalKey: monitorKey,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Monthly Overview".toUpperCase(),
                      style: GoogleFonts.ubuntu(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 1),
                  Text(DateTime.now().formattedDayAndMonthAndYear(),
                      style: GoogleFonts.ubuntu(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w400)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
              child: LogStreakMuscleTrendMonitor(
                dateTime: _monthDateTimeRange.start,
                showInfo: false,
                forceDarkMode: true,
              ),
            ),
            const SizedBox(height: 14),
          ],
        ));
  }

  void _onShareCalendar({required BuildContext context}) {
    Posthog().capture(eventName: PostHogAnalyticsEvent.shareCalendar.displayName);
    onShare(
        context: context,
        globalKey: calendarKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(_monthDateTimeRange.start.formattedMonthAndYear(),
                  textAlign: TextAlign.left,
                  style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
            ),
            Calendar(dateTime: _monthDateTimeRange.start, forceDarkMode: true),
            const SizedBox(height: 12),
            Image.asset(
              'images/trkr.png',
              fit: BoxFit.contain,
              height: 8,
              color: Colors.white70, // Adjust the height as needed
            ),
          ],
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

  void _showFireBallConfig({required BuildContext context}) {
    displayBottomSheet(
        context: context,
        child: SafeArea(
          child: Text("The fireball shows how well you're meeting your training goals for the month. The more it burns, the more on track you are. Keep training to keep it glowing!")
        ));
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/controllers/analytics_controller.dart';
import 'package:tracker_app/screens/insights/overview_screen.dart';
import 'package:tracker_app/screens/insights/sets_reps_volume_insights_screen.dart';

import '../colors.dart';
import '../utils/general_utils.dart';
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
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          body: Container(
            width: double.infinity,
            color: sapphireDark80,
            child: SafeArea(
              child: Column(
                children: [
                  Center(
                      child: CalendarNavigator(
                    onMonthChange: _onMonthChange,
                    enabled: _tabIndex == 0,
                  )),
                  TabBar(
                    controller: _tabController,
                    dividerColor: Colors.transparent,
                    tabs: [
                      Tab(
                          child: Text("Overview".toUpperCase(),
                              style:
                                  GoogleFonts.ubuntu(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700))),
                      Tab(
                          child: Text("Trends".toUpperCase(),
                              style:
                                  GoogleFonts.ubuntu(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700))),
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
                        SetsAndRepsVolumeInsightsScreen(canPop: false,)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
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

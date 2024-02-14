import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/extensions/datetime_range_extension.dart';
import 'package:tracker_app/screens/insights/streak_screen.dart';
import 'package:tracker_app/widgets/calendar/calendar_navigator.dart';
import 'package:tracker_app/widgets/monitors/overview_monitor.dart';

import '../../dtos/routine_log_dto.dart';
import '../../controllers/routine_log_controller.dart';
import '../../dtos/viewmodels/routine_log_arguments.dart';
import '../../enums/routine_editor_type_enums.dart';
import '../../strings.dart';
import '../../utils/general_utils.dart';
import '../../utils/navigation_utils.dart';
import 'package:tracker_app/utils/dialog_utils.dart';
import '../../utils/shareables_utils.dart';
import '../../widgets/buttons/text_button_widget.dart';
import '../../widgets/calendar/calendar.dart';
import '../../widgets/information_container_lite.dart';
import 'monthly_insights_screen.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  late DateTimeRange _dateTimeRange;

  void _navigateToAllDaysTracked({required BuildContext context}) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const StreakScreen()));
  }

  void _logEmptyRoutine(BuildContext context) async {
    final log = Provider.of<RoutineLogController>(context, listen: false).cachedLog();
    if (log == null) {
      final log = RoutineLogDto(
          id: "",
          templateId: "",
          name: "${timeOfDay()} Session",
          exerciseLogs: [],
          notes: "",
          startTime: DateTime.now(),
          endTime: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now());
      final arguments = RoutineLogArguments(log: log, editorMode: RoutineEditorMode.log);
      navigateToRoutineLogEditor(context: context, arguments: arguments);
    } else {
      showSnackbar(context: context, icon: const Icon(Icons.info_outline_rounded), message: "${log.name} is running");
    }
  }

  @override
  Widget build(BuildContext context) {
    final routineLogController = Provider.of<RoutineLogController>(context, listen: true);

    final logsForTheMonth = routineLogController.monthlyLogs[_dateTimeRange] ?? [];

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: "fab_overview_screen",
        onPressed: () => _logEmptyRoutine(context),
        backgroundColor: sapphireDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: const Icon(Icons.play_arrow_rounded, size: 32),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              sapphireDark80,
              sapphireDark,
            ],
          ),
        ),
        child: SafeArea(
            minimum: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  IconButton(
                    onPressed: () => _navigateToAllDaysTracked(context: context),
                    icon: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                      const FaIcon(FontAwesomeIcons.fire, color: Colors.white, size: 20),
                      const SizedBox(width: 4),
                      Text("${routineLogController.routineLogs.length}",
                          style:
                              GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                    ]),
                  ),
                  CalendarNavigator(onChangedDateTimeRange: _onChangedDateTimeRange, dateTimeRange: _dateTimeRange),
                  IconButton(
                      onPressed: () => _onShareCalendar(context: context),
                      icon: const FaIcon(FontAwesomeIcons.arrowUpFromBracket, color: Colors.white, size: 20)),
                ]),
                Expanded(
                  child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 150),
                      child: Column(children: [
                        const SizedBox(height: 10),
                        OverviewMonitor(routineLogs: logsForTheMonth),
                        const SizedBox(height: 10),
                        const InformationContainerLite(
                            content: overviewMonitor,
                            color: Colors.transparent,
                            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 12)),
                        Calendar(
                          range: _dateTimeRange,
                        ),
                        const SizedBox(height: 12),
                        MonthlyInsightsScreen(monthAndLogs: logsForTheMonth, daysInMonth: _dateTimeRange.dates.length),
                      ])),
                )
                // Add more widgets here for exercise insights
              ],
            )),
      ),
    );
  }

  void _onChangedDateTimeRange(DateTimeRange? range) {
    if (range == null) return;
    setState(() {
      _dateTimeRange = range;
    });
  }

  void _onShareCalendar({required BuildContext context}) {
    displayBottomSheet(
        color: sapphireDark,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        context: context,
        isScrollControlled: true,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          RepaintBoundary(
              key: calendarKey,
              child: Container(
                  color: sapphireDark,
                  padding: const EdgeInsets.all(8),
                  child: Calendar(readOnly: true, range: _dateTimeRange))),
          const SizedBox(height: 10),
          CTextButton(
              onPressed: () {
                captureImage(key: calendarKey, pixelRatio: 5);
                Navigator.of(context).pop();
              },
              label: "Share",
              buttonColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              buttonBorderColor: Colors.transparent)
        ]));
  }

  @override
  void initState() {
    super.initState();
    _dateTimeRange = thisMonthDateRange();
  }
}

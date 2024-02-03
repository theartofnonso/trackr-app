import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/extensions/datetime_range_extension.dart';
import 'package:tracker_app/screens/month_insight_screen.dart';
import 'package:tracker_app/screens/muscle_insights_screen.dart';
import 'package:tracker_app/screens/streak_screen.dart';
import 'package:tracker_app/widgets/information_container_lite.dart';

import '../dtos/routine_log_dto.dart';
import '../controllers/routine_log_controller.dart';
import '../enums/routine_editor_type_enums.dart';
import '../strings.dart';
import '../utils/general_utils.dart';
import '../utils/navigation_utils.dart';
import 'package:tracker_app/utils/dialog_utils.dart';
import '../utils/shareables_utils.dart';
import '../widgets/buttons/text_button_widget.dart';
import '../widgets/custom_progress_indicator.dart';
import '../widgets/calendar/calendar.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  late DateTimeRange _dateTimeRange;

  void _navigateToMuscleDistribution({required BuildContext context}) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MuscleInsightsScreen()));
  }

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
      navigateToRoutineLogEditor(context: context, log: log, editorMode: RoutineEditorMode.log);
    } else {
      showSnackbar(context: context, icon: const Icon(Icons.info_outline_rounded), message: "${log.name} is running");
    }
  }

  @override
  Widget build(BuildContext context) {
    final routineLogController = Provider.of<RoutineLogController>(context, listen: true);

    final logsForTheMonth = routineLogController.monthlyLogs[_dateTimeRange] ?? [];

    final monthlyProgress = logsForTheMonth.length / 12;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: "fab_overview_screen",
        onPressed: () => _logEmptyRoutine(context),
        backgroundColor: sapphireLighter,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: const Icon(Icons.play_arrow_rounded, size: 32),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 150),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  IconButton(
                      onPressed: () => _onShareCalendar(context: context),
                      icon: const FaIcon(FontAwesomeIcons.arrowUpFromBracket, color: Colors.white, size: 20)),
                ]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => navigateToRoutineLogs(context: context, logs: logsForTheMonth),
                      child: CustomProgressIndicator(
                        value: monthlyProgress,
                        valueText: "${logsForTheMonth.length}",
                      ),
                    ),
                    const SizedBox(width: 20),
                    InkWell(
                      onTap: () => _navigateToAllDaysTracked(context: context),
                      child: _CTableCell(
                          title: "STREAK",
                          subtitle: "${routineLogController.routineLogs.length}",
                          crossAxisAlignment: CrossAxisAlignment.end),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const InformationContainerLite(
                    content: consistencyMonitor,
                    color: Colors.transparent,
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 12)),
                Theme(
                  data: ThemeData(splashColor: sapphireLight),
                  child: ListTile(
                      onTap: () => _navigateToMuscleDistribution(context: context),
                      tileColor: sapphireLight,
                      dense: true,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      title: Text("Muscle insights",
                          style:
                              GoogleFonts.montserrat(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      trailing: Text("sets", style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 14))),
                ),
                const SizedBox(height: 10),
                Calendar(onChangedDateTimeRange: _onChangedDateTimeRange),
                const SizedBox(height: 12),
                MonthInsightsScreen(monthAndLogs: logsForTheMonth, daysInMonth: _dateTimeRange.dates.length),
              ],
            )),
      ),
    );
  }

  void _onChangedDateTimeRange(DateTimeRange range) {
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
                  color: sapphireDark, padding: const EdgeInsets.all(8), child: const Calendar(readOnly: true))),
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

class _CTableCell extends StatelessWidget {
  final String title;
  final String subtitle;
  final CrossAxisAlignment crossAxisAlignment;

  const _CTableCell({required this.title, required this.subtitle, required this.crossAxisAlignment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(crossAxisAlignment: crossAxisAlignment, children: [
        Text(title, style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w600)),
        Text(subtitle, style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24)),
      ]),
    );
  }
}

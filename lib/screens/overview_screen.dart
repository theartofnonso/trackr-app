import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/screens/streak_screen.dart';
import 'package:tracker_app/screens/muscle_insights_screen.dart';
import 'package:tracker_app/screens/settings_screen.dart';

import '../dtos/routine_log_dto.dart';
import '../controllers/routine_log_controller.dart';
import '../enums/routine_editor_type_enums.dart';
import '../utils/general_utils.dart';
import '../utils/navigation_utils.dart';
import 'package:tracker_app/utils/dialog_utils.dart';
import '../utils/shareables_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/buttons/text_button_widget.dart';
import 'calendar_screen.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  void _navigateToSettings() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
    setState(() {});
  }

  void _navigateToMuscleDistribution() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MuscleInsightsScreen()));
  }

  void navigateToAllDaysTracked() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const StreakScreen()));
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

    final weeklyLogs = routineLogController.weeklyLogs;

    final logsForTheWeek = weeklyLogs[thisWeekDateRange()] ?? [];
    final logsForTheMonth = routineLogController.monthlyLogs[thisMonthDateRange()] ?? [];

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: "fab_overview_screen",
        onPressed: () => _logEmptyRoutine(context),
        backgroundColor: tealBlueLighter,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: const Icon(Icons.play_arrow_rounded, size: 32),
      ),
      appBar: AppBar(
        title: GestureDetector(
          onTap: navigateToAllDaysTracked,
          child: Row(
            children: [
              const FaIcon(FontAwesomeIcons.fire, color: Colors.green),
              const SizedBox(width: 10),
              Text("${routineLogController.routineLogs.length} days", style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15))
            ]
          ),
        ),
        centerTitle: false,
        actions: [
          GestureDetector(
            onTap: _navigateToSettings,
            child: const Padding(
              padding: EdgeInsets.only(right: 14.0),
              child: Icon(Icons.settings),
            ),
          ),
          IconButton(
              onPressed: _onShareCalendar,
              icon: const FaIcon(FontAwesomeIcons.arrowUpFromBracket, color: Colors.white, size: 18))
        ],
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 150),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Table(
                          border: TableBorder.symmetric(inside: const BorderSide(color: tealBlueLighter, width: 2)),
                          columnWidths: const <int, TableColumnWidth>{
                            0: FlexColumnWidth(),
                            1: FlexColumnWidth(),
                          },
                          children: [
                            TableRow(children: [
                              _CTableCell(
                                  title: "This Week",
                                  subtitle:
                                      "${logsForTheWeek.length} ${pluralize(word: "session", count: logsForTheWeek.length)}",
                                  onTap: () => navigateToRoutineLogs(context: context, logs: logsForTheWeek)),
                              _CTableCell(
                                  title: "This Month",
                                  subtitle:
                                      "${logsForTheMonth.length} ${pluralize(word: "session", count: logsForTheMonth.length)}",
                                  onTap: () => navigateToRoutineLogs(context: context, logs: logsForTheMonth))
                            ])
                          ],
                        )),
                  ],
                ),
                const SizedBox(height: 20),
                Theme(
                  data: ThemeData(splashColor: tealBlueLight),
                  child: ListTile(
                      onTap: _navigateToMuscleDistribution,
                      tileColor: tealBlueLight,
                      dense: true,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      title: Text("Muscle insights",
                          style:
                              GoogleFonts.montserrat(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      subtitle: Text("Number of sets logged per muscle group",
                          style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 14))),
                ),
                const SizedBox(height: 20),
                /// Do not make this a const
                CalendarScreen()
              ],
            )),
      ),
    );
  }

  void _onShareCalendar() {
    displayBottomSheet(
        color: tealBlueDark,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        context: context,
        isScrollControlled: true,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          RepaintBoundary(
              key: calendarKey,
              child: Container(
                  color: tealBlueDark,
                  padding: const EdgeInsets.all(8),
                  child: CalendarScreen(readOnly: true))),
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

}

class _CTableCell extends StatelessWidget {
  final String title;
  final String subtitle;
  final void Function() onTap;

  const _CTableCell({required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Text(title, style: GoogleFonts.montserrat(fontSize: 15, color: Colors.white70, fontWeight: FontWeight.w500)),
        Text(subtitle, style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15))
      ]),
    );
  }
}

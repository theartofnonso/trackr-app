import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/screens/muscle_insights_screen.dart';
import 'package:tracker_app/screens/settings_screen.dart';

import '../dtos/routine_log_dto.dart';
import '../providers/routine_log_provider.dart';
import '../utils/general_utils.dart';
import '../utils/navigation_utils.dart';
import 'package:tracker_app/widgets/helper_widgets/dialog_helper.dart';
import 'calendar_screen.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  void _navigateBack(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
  }

  void _navigateToMuscleDistribution(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MuscleInsightsScreen()));
  }

  void _logEmptyRoutine(BuildContext context) async {
    final log = cachedRoutineLog();
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
      navigateToRoutineLogEditor(context: context, log: log);
    } else {
      showSnackbar(context: context, icon: const Icon(Icons.info_outline_rounded), message: "${log.name} is running");
    }
  }

  @override
  Widget build(BuildContext context) {
    final routineLogProvider = Provider.of<RoutineLogProvider>(context, listen: true);

    final logsForTheWeek = routineLogProvider.weekToLogs[thisWeekDateRange()] ?? [];
    final logsForTheMonth = routineLogProvider.monthToLogs[thisMonthDateRange()] ?? [];

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: "fab_overview_screen",
        onPressed: () => _logEmptyRoutine(context),
        backgroundColor: tealBlueLighter,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: const Icon(Icons.play_arrow_rounded, size: 32),
      ),
      appBar: AppBar(
        title: Image.asset(
          'assets/trackr.png',
          fit: BoxFit.contain,
          height: 14, // Adjust the height as needed
        ),
        centerTitle: false,
        actions: [
          GestureDetector(
            onTap: () => _navigateBack(context),
            child: const Padding(
              padding: EdgeInsets.only(right: 14.0),
              child: Icon(Icons.settings),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 150),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
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
                              2: FlexColumnWidth(),
                            },
                            children: [
                              TableRow(children: [
                                _CTableCell(
                                    title: "This Week",
                                    subtitle: "${logsForTheWeek.length} sessions",
                                    onTap: () => navigateToRoutineLogs(context: context, logs: logsForTheWeek)),
                                _CTableCell(
                                    title: "This Month",
                                    subtitle: "${logsForTheMonth.length} sessions",
                                    onTap: () => navigateToRoutineLogs(context: context, logs: logsForTheMonth)),
                                _CTableCell(
                                    title: "Level",
                                      subtitle: "Coming",
                                    onTap: () => {})
                              ])
                            ],
                          )),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Theme(
                    data: ThemeData(splashColor: tealBlueLight),
                    child: ListTile(
                        onTap: () => _navigateToMuscleDistribution(context),
                        tileColor: tealBlueLight,
                        dense: true,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        title: Text("Muscle insights", style: GoogleFonts.montserrat(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                        subtitle: Text("Number of sets logged for each muscle group",
                            style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 14))),
                  ),
                  const SizedBox(height: 20),
                  const CalendarScreen()
                ],
              ),
            )),
      ),
    );
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/widgets/empty_states/list_view_empty_state.dart';
import 'package:tracker_app/widgets/banners/pending_routines_banner.dart';

import '../../../app_constants.dart';
import '../../../models/RoutineLog.dart';
import '../../../providers/routine_log_provider.dart';
import '../../utils/general_utils.dart';
import '../../utils/navigation_utils.dart';
import '../calendar_screen.dart';
import '../editors/routine_editor_screen.dart';

class RoutineLogsScreen extends StatefulWidget {
  const RoutineLogsScreen({super.key});

  @override
  State<RoutineLogsScreen> createState() => _RoutineLogsScreenState();
}

class _RoutineLogsScreenState extends State<RoutineLogsScreen> {
  void _navigateToCalendarScreen() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CalendarScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Consumer<RoutineLogProvider>(builder: (_, provider, __) {
      final cachedPendingLogs = provider.cachedPendingLogs;

      return Scaffold(
        appBar: AppBar(
          title: Image.asset(
            'assets/trackr.png',
            fit: BoxFit.contain,
            height: 14, // Adjust the height as needed
          ),
          centerTitle: false,
          actions: [
            GestureDetector(
              onTap: _navigateToCalendarScreen,
              child: const Padding(
                padding: EdgeInsets.only(right: 14.0),
                child: Icon(Icons.calendar_month_rounded),
              ),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
                heroTag: "fab_routine_logs_screen",
                onPressed: () {
                  navigateToRoutineEditor(context: context, mode: RoutineEditorMode.log);
                },
                backgroundColor: tealBlueLighter,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                label: Text("Empty Workout", style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
              ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
            child: Column(
              children: [
                cachedPendingLogs.isNotEmpty ? PendingRoutinesBanner(logs: cachedPendingLogs) : const SizedBox.shrink(),
                provider.logs.isNotEmpty
                    ? Expanded(
                        child: RefreshIndicator(
                          onRefresh: () => loadAppData(context),
                          child: ListView.separated(
                              padding: const EdgeInsets.only(bottom: 150),
                              itemBuilder: (BuildContext context, int index) =>
                                  _RoutineLogWidget(log: provider.logs[index]),
                              separatorBuilder: (BuildContext context, int index) =>
                                  Divider(color: Colors.white70.withOpacity(0.1)),
                              itemCount: provider.logs.length),
                        ),
                      )
                    : ListViewEmptyState(onRefresh: () => loadAppData(context)),
              ],
            ),
          ),
        ),
      );
    }));
  }
}

class _RoutineLogWidget extends StatelessWidget {
  final RoutineLog log;

  const _RoutineLogWidget({required this.log});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(splashColor: tealBlueLight),
      child: ListTile(
        onTap: () => navigateToRoutineLogPreview(context: context, logId: log.id),
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        title: Text(log.name, style: GoogleFonts.lato(color: Colors.white, fontSize: 14 )),
        subtitle: Text("${log.procedures.length} exercise(s)",
            style: GoogleFonts.lato(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500, fontSize: 14)),
        trailing: Text(log.createdAt.getDateTimeInUtc().durationSinceOrDate(),
            style: GoogleFonts.lato(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500, fontSize: 14)),
      ),
    );
  }
}

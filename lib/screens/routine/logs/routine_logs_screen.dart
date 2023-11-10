import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/extensions/routine_log_extension.dart';
import 'package:tracker_app/messages.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import 'package:tracker_app/widgets/empty_states/screen_empty_state.dart';
import 'package:tracker_app/widgets/banners/pending_routines_banner.dart';

import '../../../app_constants.dart';
import '../../../helper_functions/navigation/navigator_helper_functions.dart';
import '../../../models/RoutineLog.dart';
import '../../../providers/exercise_provider.dart';
import '../../../providers/routine_log_provider.dart';
import '../../../providers/routine_provider.dart';
import '../../../widgets/banners/minimised_routine_banner.dart';
import '../../calendar_screen.dart';

class RoutineLogsScreen extends StatefulWidget {
  const RoutineLogsScreen({super.key});

  @override
  State<RoutineLogsScreen> createState() => _RoutineLogsScreenState();
}

class _RoutineLogsScreenState extends State<RoutineLogsScreen> with WidgetsBindingObserver {
  void _navigateToCalendarScreen() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CalendarScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Consumer<RoutineLogProvider>(builder: (_, provider, __) {
      final cachedRoutineLog = provider.cachedLog;
      final cachedPendingLogs = provider.cachedPendingLogs;

      return Scaffold(
        appBar: AppBar(
          title: Text("Home", style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.w600)),
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
        floatingActionButton: cachedRoutineLog == null
            ? FloatingActionButton(
                heroTag: "fab_routine_logs_screen",
                onPressed: () {
                  startEmptyRoutine(context: context);
                },
                backgroundColor: tealBlueLighter,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                child: const Icon(Icons.play_arrow_rounded),
              )
            : null,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: [
                cachedPendingLogs.isNotEmpty ? PendingRoutinesBanner(logs: cachedPendingLogs) : const SizedBox.shrink(),
                cachedRoutineLog != null ? MinimisedRoutineBanner(log: cachedRoutineLog) : const SizedBox.shrink(),
                provider.logs.isNotEmpty
                    ? Expanded(
                        child: ListView.separated(
                            itemBuilder: (BuildContext context, int index) =>
                                _RoutineLogWidget(log: provider.logs[index]),
                            separatorBuilder: (BuildContext context, int index) =>
                                Divider(color: Colors.white70.withOpacity(0.1)),
                            itemCount: provider.logs.length),
                      )
                    : Expanded(
                        child: Center(
                            child: ScreenEmptyState(
                                message: cachedRoutineLog == null
                                    ? startTrackingPerformance
                                    : crunchingPerformanceNumbers))),
              ],
            ),
          ),
        ),
      );
    }));
  }

  void _loadData() async {
    await Provider.of<ExerciseProvider>(context, listen: false).listExercises();
    if (mounted) {
      final routineLogProvider = Provider.of<RoutineLogProvider>(context, listen: false);
      routineLogProvider.listRoutineLogs(context);
      routineLogProvider.retrieveCachedRoutineLog(context);
      routineLogProvider.retrieveCachedPendingRoutineLog(context);
      Provider.of<RoutineProvider>(context, listen: false).listRoutines(context);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => Provider.of<RoutineLogProvider>(context, listen: false).listRoutineLogs(context));
    }
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
        //tileColor: tealBlueLight,
        onTap: () => navigateToRoutineLogPreview(context: context, logId: log.id),
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        title: Text(log.name, style: Theme.of(context).textTheme.labelLarge),
        subtitle: Text(log.createdAt.getDateTimeInUtc().durationSinceOrDate(),
            style: GoogleFonts.lato(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500, fontSize: 12)),
        trailing: Text(log.durationInString(),
            style: GoogleFonts.lato(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500, fontSize: 12)),
      ),
    );
  }
}

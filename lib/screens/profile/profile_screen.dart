import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/screens/muscle_insights_screen.dart';
import 'package:tracker_app/screens/settings_screen.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/widgets/empty_states/list_tile_empty_state.dart';
import 'package:tracker_app/widgets/empty_states/list_view_empty_state.dart';
import 'package:tracker_app/widgets/empty_states/screen_empty_state.dart';

import '../../models/RoutineLog.dart';
import '../../providers/routine_log_provider.dart';
import '../../utils/general_utils.dart';
import '../../widgets/banners/minimised_routine_banner.dart';
import '../../widgets/banners/pending_routines_banner.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _navigateBack(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
  }

  void _navigateToMuscleDistribution(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MuscleInsightsScreen()));
  }

  int _logsForTheWeekCount({required List<RoutineLog> logs}) {
    final thisWeek = thisWeekDateRange();
    return logs.where((log) => log.createdAt.getDateTimeInUtc().isBetweenRange(range: thisWeek)).toList().length;
  }

  int _logsForTheMonthCount({required List<RoutineLog> logs}) {
    final thisMonth = thisMonthDateRange();
    return logs.where((log) => log.createdAt.getDateTimeInUtc().isBetweenRange(range: thisMonth)).toList().length;
  }

  int _logsForTheYearCount({required List<RoutineLog> logs}) {
    final thisYear = thisYearDateRange();
    return logs.where((log) => log.createdAt.getDateTimeInUtc().isBetweenRange(range: thisYear)).toList().length;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RoutineLogProvider>(context, listen: true);

    final cachedRoutineLog = provider.cachedLog;
    final cachedPendingLogs = provider.cachedPendingLogs;

    final logs = provider.logs;
    final earliestLog = logs.lastOrNull;
    final logsForTheWeek = _logsForTheWeekCount(logs: logs);
    final logsForTheMonth = _logsForTheMonthCount(logs: logs);
    final logsForTheYear = _logsForTheYearCount(logs: logs);

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
            onTap: () => _navigateBack(context),
            child: const Padding(
              padding: EdgeInsets.only(right: 14.0),
              child: Icon(Icons.settings),
            ),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => loadAppData(context),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(), // Enable scrolling even when the content is smaller than the screen
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  cachedPendingLogs.isNotEmpty ? PendingRoutinesBanner(logs: cachedPendingLogs) : const SizedBox.shrink(),
                  cachedRoutineLog != null ? MinimisedRoutineBanner(log: cachedRoutineLog) : const SizedBox.shrink(),
                  if(logs.isNotEmpty)
                    RichText(
                    text: TextSpan(
                      style: GoogleFonts.lato(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 15),
                      // This gets the default style
                      children: <TextSpan>[
                        const TextSpan(text: 'You have logged '),
                        TextSpan(
                            text: '$logsForTheWeek workout(s) this week,',
                            style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white)),
                        TextSpan(
                            text: ' $logsForTheMonth this month',
                            style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white)),
                        const TextSpan(text: ' and '),
                        TextSpan(
                            text: '$logsForTheYear this year',
                            style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white))
                      ],
                    ),
                  ),
                    const SizedBox(height: 10),
                  if(logs.isNotEmpty)
                    Text(
                      "${logs.length} workouts since ${earliestLog?.createdAt.getDateTimeInUtc().formattedDayAndMonthAndYear()}",
                      style: GoogleFonts.lato(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 15)),
                  if(logs.isEmpty)
                    const ListTileEmptyState(),
                  const SizedBox(height: 20),
                  Theme(
                    data: ThemeData(splashColor: tealBlueLight),
                    child: ListTile(
                        onTap: () => _navigateToMuscleDistribution(context),
                        tileColor: tealBlueLight,
                        dense: true,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                        title: Text("Muscle insights", style: GoogleFonts.lato(color: Colors.white, fontSize: 16)),
                        subtitle: Text("Number of sets logged for each muscle group",
                            style: GoogleFonts.lato(color: Colors.white70, fontSize: 14))),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

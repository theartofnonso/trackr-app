import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/screens/muscle_distribution_screen.dart';
import 'package:tracker_app/screens/settings_screen.dart';
import 'package:tracker_app/utils/datetime_utils.dart';

import '../../models/RoutineLog.dart';
import '../../providers/routine_log_provider.dart';

DateTimeRange thisWeekDateRange() {
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final endOfWeek = now.add(Duration(days: 7 - now.weekday));
  return DateTimeRange(start: startOfWeek, end: endOfWeek);
}

DateTimeRange thisMonthDateRange() {
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final endOfMonth = DateTime(now.year, now.month + 1, 0);
  return DateTimeRange(start: startOfMonth, end: endOfMonth);
}

DateTimeRange thisYearDateRange() {
  final now = DateTime.now();
  final startOfYear = DateTime(now.year, 1, 1);
  final endOfYear = DateTime(now.year, 12, 31);
  return DateTimeRange(start: startOfYear, end: endOfYear);
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _navigateBack(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
  }

  void _navigateToMuscleDistribution(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MuscleDistributionScreen()));
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
    final logs = provider.logs;
    final earliestLog = logs.lastOrNull;
    final logsForTheWeek = _logsForTheWeekCount(logs: logs);
    final logsForTheMonth = _logsForTheMonthCount(logs: logs);
    final logsForTheYear = _logsForTheYearCount(logs: logs);

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile", style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.w600)),
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
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Text(
                      "${logs.length} workouts since ${earliestLog?.createdAt.getDateTimeInUtc().formattedDayAndMonthAndYear()}",
                      style: GoogleFonts.lato(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 15)),
                ],
              ),
              const SizedBox(height: 20),
              Theme(
                data: ThemeData(splashColor: tealBlueLight),
                child: ListTile(
                    onTap: () => _navigateToMuscleDistribution(context),
                    tileColor: tealBlueLight,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                    title: Text("Muscle distribution", style: Theme.of(context).textTheme.labelLarge),
                    subtitle: Text("Number of sets logged for each muscle group",
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white70))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

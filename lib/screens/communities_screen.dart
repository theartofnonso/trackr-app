import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/extensions/routine_log_extension.dart';
import 'package:tracker_app/utils/string_utils.dart';

import '../colors.dart';
import '../models/RoutineLog.dart';
import '../utils/date_utils.dart';
import '../utils/https_utils.dart';
import '../widgets/backgrounds/trkr_loading_screen.dart';
import '../widgets/monitors/log_streak_monitor.dart';

class CommunitiesScreen extends StatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen> {
  bool _loading = false;

  List<dynamic> _userAndRoutineLogs = [];

  @override
  Widget build(BuildContext context) {
    if (_loading) return TRKRLoadingScreen(action: _hideLoadingScreen);

    return Scaffold(
        body: SafeArea(
            child: ListView.builder(
                itemCount: _userAndRoutineLogs.length,
                itemBuilder: (BuildContext context, int index) {
                  final userAndRoutineLogs = _userAndRoutineLogs[index];
                  final user = userAndRoutineLogs["user"] as String;
                  final streakScore = userAndRoutineLogs["streakScore"] as double;
                  final streakDays = userAndRoutineLogs["streakDays"] as int;
                  return _LeaderBoardItem(
                      leading: streakScore,
                      title: "User-${user.substring(0, 5)}".toUpperCase(),
                      subTitle: "A subtitle",
                      trailing: "$streakDays ${pluralize(word: "Day", count: streakDays)}");
                })));
  }

  void _loadData() {
    _showLoadingScreen();
    final dateRange = yearToDateTimeRange();
    final startOfCurrentYear = dateRange.start.toIso8601String();
    final endOfCurrentYear = dateRange.end.toIso8601String();

    getAPI(endpoint: "/routine-logs", queryParameters: {"start": startOfCurrentYear, "end": endOfCurrentYear})
        .then((response) {
      if (response.isNotEmpty) {
        final json = jsonDecode(response);
        final data = json["data"];
        final body = data["listRoutineLogs"];
        final items = body["items"] as List<dynamic>;
        final routineLogs = items.map((item) => RoutineLog.fromJson(item).dto());
        final routineLogsByUser = groupBy(routineLogs, (routineLog) => routineLog.owner);
        _userAndRoutineLogs = routineLogsByUser.entries.map((routineLogsAndUser) {
          final routineLogs = routineLogsAndUser.value;
          final routineLogsByDay = groupBy(routineLogs, (log) => log.createdAt.withoutTime().day);
          final monthlyProgress = routineLogsByDay.length / 144;
          return {"user": routineLogsAndUser.key, "streakScore": monthlyProgress, "streakDays": routineLogs.length};
        }).toList();
      }
      _hideLoadingScreen();
    });
  }

  void _showLoadingScreen() {
    setState(() {
      _loading = true;
    });
  }

  void _hideLoadingScreen() {
    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }
}

class _LeaderBoardItem extends StatelessWidget {
  final double leading;
  final String title;
  final String subTitle;
  final String trailing;

  const _LeaderBoardItem({required this.leading, required this.title, required this.subTitle, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: LogStreakMonitor(
          value: leading,
          width: 35,
          height: 35,
          strokeWidth: 3,
          decoration: BoxDecoration(
            color: sapphireDark.withOpacity(0.35),
            borderRadius: BorderRadius.circular(100),
          )),
      title: Text(title, style: GoogleFonts.ubuntu(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)),
      subtitle:
          Text(subTitle, style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500, color: Colors.white70, fontSize: 14)),
      trailing:
          Text(trailing, style: GoogleFonts.ubuntu(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)),
    );
  }
}

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/enums/chart_period_enum.dart';
import 'package:tracker_app/screens/insights/leaderboard/log_streak_leaderboard.dart';
import 'package:tracker_app/screens/insights/leaderboard/muscle_score_leaderboard.dart';
import 'package:tracker_app/widgets/backgrounds/gradient_widget.dart';

import '../../../colors.dart';
import '../../../dtos/exercise_log_dto.dart';
import '../../../dtos/routine_log_dto.dart';
import '../../../utils/general_utils.dart';
import '../../../utils/https_utils.dart';
import '../../../widgets/calendar/calendar_navigator.dart';
import '../../../widgets/empty_states/leader_board_empty_state.dart';

class LeaderBoardScreen extends StatefulWidget {
  static const routeName = '/leader-board';

  const LeaderBoardScreen({super.key});

  @override
  State<LeaderBoardScreen> createState() => _LeaderBoardScreenState();
}

class _LeaderBoardScreenState extends State<LeaderBoardScreen> {
  late DateTimeRange _dateTimeRange;

  Map<String, List<RoutineLogDto>> _routineLogs = {};

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
              flexibleSpace: GradientWidget(
                child: Image.asset(
                  'images/man_woman.jpg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              leading: IconButton(
                icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
              bottom: TabBar(
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(
                      child: Text("Log Streak",
                          style:
                              GoogleFonts.montserrat(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600))),
                  Tab(
                      child: Text("Muscle Score",
                          style:
                              GoogleFonts.montserrat(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600))),
                ],
              )),
          body: Stack(children: [
            Container(
              width: double.infinity,
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
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    CalendarNavigator(
                        onChangedDateTimeRange: _onChangedDateTimeRange,
                        chartPeriod: ChartPeriod.month,
                        dateTimeRange: _dateTimeRange),
                    _routineLogs.isNotEmpty
                        ? Expanded(
                            child: TabBarView(
                              children: [
                                LogStreakLeaderBoard(routineLogs: _routineLogs),
                                MuscleScoreLeaderBoard(routineLogs: _routineLogs)
                              ],
                            ),
                          )
                        : const LeaderBoardEmptyState(),
                  ],
                ),
              ),
            ),
          ]),
        ));
  }

  void _onChangedDateTimeRange(DateTimeRange? range) {
    if (range == null) return;
    _dateTimeRange = range;
    setState(() {
      _makeAPICall();
    });
  }

  void _makeAPICall() {
    final Map<String, String> filter = {
      "start": _dateTimeRange.start.toIso8601String(),
      "end": _dateTimeRange.end.toIso8601String(),
    };

    getAPI(endpoint: '/routine-logs', queryParameters: filter).then((response) {
      final json = jsonDecode(response);
      final data = json["data"];
      final logs = data["listRoutineLogs"];
      final items = logs["items"] as List<dynamic>;
      final logDTOs = items.map((item) => _dto(json: item)).toList();
      setState(() {
        _routineLogs = groupBy(logDTOs, (log) => log.id);
      });
    });
  }

  @override
  void initState() {
    super.initState();

    _dateTimeRange = thisMonthDateRange();

    _makeAPICall();
  }

  RoutineLogDto _dto({required dynamic json}) {
    final id = json["id"] ?? "";
    final owner = json["owner"];
    final data = json["data"];
    final dataJson = jsonDecode(data);
    final name = dataJson["name"];
    final exerciseLogJsons = dataJson["exercises"] as List<dynamic>;
    final exerciseLogs = exerciseLogJsons
        .map((json) => ExerciseLogDto.fromJson(routineLogId: id, createdAt: DateTime.now(), json: jsonDecode(json)))
        .toList();
    return RoutineLogDto(
      id: owner,
      templateId: "",
      name: name,
      exerciseLogs: exerciseLogs,
      notes: "",
      startTime: DateTime.now(),
      endTime: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/achievement_dto.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/extensions/routine_log_extension.dart';
import 'package:tracker_app/widgets/empty_states/achievements_empty_state.dart';

import '../../colors.dart';
import '../../controllers/routine_log_controller.dart';
import '../../dtos/routine_log_dto.dart';
import '../../widgets/achievements/achievement_tile.dart';
import '../../widgets/backgrounds/overlay_background.dart';
import '../../widgets/calendar/calendar_years_navigator.dart';
import 'achievement_screen.dart';

class AchievementsScreen extends StatefulWidget {
  final ScrollController? scrollController;

  static const routeName = '/achievements_screen';

  const AchievementsScreen({super.key, this.scrollController});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  List<RoutineLogDto>? _routineLogs;

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final routineLogController = Provider.of<RoutineLogController>(context, listen: false);

    final logs = _routineLogs ?? routineLogController.routineLogs;

    List<AchievementDto> achievements = [];

    if (logs.isNotEmpty) {
      achievements =
          routineLogController.fetchAchievements(logs: _routineLogs).sorted((a, b) => b.progress.value.compareTo(a.progress.value));
    }

    return Scaffold(
        body: Container(
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
      child: Stack(children: [
        SafeArea(
            minimum: const EdgeInsets.all(10.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              const SizedBox(height: 10),
              Text("Milestones".toUpperCase(),
                  style: GoogleFonts.montserrat(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              CalendarYearsNavigator(onChangedDateTimeRange: _onChangedDateTimeRange),
              const SizedBox(height: 10),
              logs.isNotEmpty
                  ? Expanded(child: _AchievementListView(children: achievements))
                  : const AchievementsEmptyState()
            ])),
        if (_loading) const OverlayBackground(opacity: 0.9)
      ]),
    ));
  }

  void _onChangedDateTimeRange(DateTimeRange? range) {
    if (range == null) return;

    setState(() {
      _loading = true;
    });

    final routineLogController = Provider.of<RoutineLogController>(context, listen: false);

    routineLogController.fetchLogsCloud(range: range.start.dateTimeRange()).then((logs) {
      setState(() {
        _loading = false;
        _routineLogs = logs.map((log) => log.dto()).sorted((a, b) => a.createdAt.compareTo(b.createdAt));
      });
    });
  }
}

class _AchievementListView extends StatelessWidget {
  final List<AchievementDto> children;

  const _AchievementListView({required this.children});

  @override
  Widget build(BuildContext context) {
    final widgets = children.map((achievement) {
      return AchievementTile(
        achievement: achievement,
        margin: const EdgeInsets.only(bottom: 10),
        onTap: () {
          _navigateToAchievement(context: context, achievement: achievement);
        },
      );
    }).toList();

    return SingleChildScrollView(child: Column(children: widgets));
  }

  void _navigateToAchievement({required BuildContext context, required AchievementDto achievement}) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => AchievementScreen(achievementDto: achievement)));
  }
}

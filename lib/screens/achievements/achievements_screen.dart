import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/achievement_dto.dart';
import 'package:tracker_app/widgets/empty_states/achievements_empty_state.dart';

import '../../app_constants.dart';
import '../../controllers/routine_log_controller.dart';
import '../../widgets/achievements/achievement_tile.dart';
import '../../widgets/information_container_lite.dart';
import 'achievement_screen.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final routineLogController = Provider.of<RoutineLogController>(context, listen: false);

    final logs = routineLogController.routineLogs;

    List<AchievementDto> achievements = [];

    if (logs.isNotEmpty) {
      achievements =
          routineLogController.fetchAchievements().sorted((a, b) => b.progress.value.compareTo(a.progress.value));
    }

    return Scaffold(
        body: SafeArea(
            minimum: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 10),
                Text("Milestones ${DateTime.now().year}",
                    style: GoogleFonts.montserrat(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                const SizedBox(height: 16),
                const InformationContainerLite(
                  content: 'Only workouts logged in the current year will count towards your achievements.',
                  color: tealBlueLighter,
                ),
                const SizedBox(height: 20),
                logs.isNotEmpty ? _AchievementListView(children: achievements) : const AchievementsEmptyState()
              ]),
            )));
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

    return Column(children: widgets);
  }

  void _navigateToAchievement({required BuildContext context, required AchievementDto achievement}) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => AchievementScreen(achievementDto: achievement)));
  }
}

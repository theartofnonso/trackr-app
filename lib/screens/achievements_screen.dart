import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/dtos/achievement_dto.dart';

import '../app_constants.dart';
import '../enums/achievement_type_enums.dart';
import '../providers/achievements_provider.dart';
import '../widgets/backgrounds/gradient_background.dart';
import 'achievement_screen.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  List<AchievementDto> _achievements({required BuildContext context}) {
    return AchievementType.values.map((achievementType) {
      final progress = calculateProgress(context: context, type: achievementType);
      return AchievementDto(type: achievementType, progress: progress);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final achievements = _achievements(context: context);

    return Scaffold(
        body: Stack(children: [
      const Positioned.fill(child: GradientBackground()),
      SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 10),
            Text("Achievements",
                style: GoogleFonts.lato(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Text("Keep logging your sessions to achieve milestones and unlock badges.",
                style: GoogleFonts.lato(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 20),
            _AchievementListView(children: achievements)
          ]),
        ),
      ))
    ]));
  }
}

class _AchievementListView extends StatelessWidget {
  final List<AchievementDto> children;

  const _AchievementListView({required this.children});

  @override
  Widget build(BuildContext context) {
    final widgets = children.map((achievement) {
      return _AchievementTile(
        achievement: achievement,
        margin: const EdgeInsets.only(bottom: 10),
      );
    }).toList();

    return Column(children: widgets);
  }
}

class _AchievementTile extends StatelessWidget {
  final AchievementDto achievement;
  final EdgeInsets margin;

  const _AchievementTile({required this.achievement, required this.margin});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _navigateToAchievement(context);
      },
      child: Container(
          padding: const EdgeInsets.all(8),
          margin: margin,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0), //
              border: Border.all(color: tealBlueLighter, width: 2) // Set the border radius here
              ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(achievement.type.title.toUpperCase(),
                            style: GoogleFonts.lato(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Text(achievement.type.description, style: GoogleFonts.lato(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      color: achievement.progress.progressRemainder == 0 ? Colors.green : Colors.white,
                      value: achievement.progress.progressValue,
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      backgroundColor: tealBlueLighter,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text("${achievement.progress.progressRemainder} left",
                  style: GoogleFonts.lato(color: Colors.white70, fontSize: 12)),
            ],
          )),
    );
  }

  void _navigateToAchievement(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AchievementScreen(achievementDto: achievement)));
  }
}

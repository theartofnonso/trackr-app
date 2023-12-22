import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/achievement_dto.dart';
import 'package:tracker_app/models/ModelProvider.dart';
import 'package:tracker_app/providers/routine_log_provider.dart';

import '../app_constants.dart';
import '../enums/achievement_type_enums.dart';
import '../providers/achievements_provider.dart';
import '../widgets/backgrounds/gradient_background.dart';

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
            _CListView(children: achievements)
          ]),
        ),
      ))
    ]));
  }
}

class _CListView extends StatelessWidget {
  final List<AchievementDto> children;

  const _CListView({required this.children});

  @override
  Widget build(BuildContext context) {
    final widgets = children.map((achievement) {
      return _CListTile(
        title: achievement.type.title,
        subtitle: achievement.type.description,
        progressValue: achievement.progress.progress,
        progressRemainder: achievement.progress.difference,
        margin: const EdgeInsets.only(bottom: 10),
      );
    }).toList();

    return Column(children: widgets);
  }
}

class _CListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progressValue;
  final int progressRemainder;
  final EdgeInsets margin;

  const _CListTile(
      {required this.title,
      required this.subtitle,
      required this.progressValue,
      required this.progressRemainder,
      required this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                      Text(title.toUpperCase(),
                          style: GoogleFonts.lato(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Text(subtitle, style: GoogleFonts.lato(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    color: progressRemainder == 0 ? Colors.green : Colors.white,
                    value: progressValue,
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    backgroundColor: tealBlueLighter,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text("$progressRemainder left", style: GoogleFonts.lato(color: Colors.white70, fontSize: 12)),
          ],
        ));
  }
}

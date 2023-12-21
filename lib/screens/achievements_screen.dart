import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/providers/routine_log_provider.dart';

import '../app_constants.dart';
import '../enums/achievement_type_enums.dart';
import '../widgets/backgrounds/gradient_background.dart';

class AchievementsScreen extends StatelessWidget {

  ({int difference, double progress}) _calculateAchievementProgress({required BuildContext context, required AchievementType type}) {
    return switch (type) {
      AchievementType.days12 => _calculateDaysProgress(context: context, type: type),
      AchievementType.days30 => _calculateDaysProgress(context: context, type: type),
      AchievementType.days75 => _calculateDaysProgress(context: context, type: type),
      AchievementType.days100 => _calculateDaysProgress(context: context, type: type),
      _ => (progress: 0, difference: 0)
    };
  }

  ({int difference, double progress}) _calculateDaysProgress({required BuildContext context, required AchievementType type}) {
    final logs = Provider.of<RoutineLogProvider>(context, listen: false).logs;
    final targetDays = switch(type) {
      AchievementType.days12 => 12,
      AchievementType.days30 => 30,
      AchievementType.days75 => 75,
      AchievementType.days100 => 100,
      _ => 0,
    };

    final difference = targetDays - logs.length;

    final progress = logs.length / targetDays;

    return (progress: progress, difference: difference);
  }

  const AchievementsScreen({super.key});


  List<Widget> _achievementToWidgets() {
    AchievementType.values.map((e) {
      _CListTile(title: "", subtitle: "", progressValue: 0.1, progressRemainder: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
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
               _CListTile(
                title: "12 Days Trackd",
                subtitle: "Log at least 3 sessions per week for a month",
                progressValue: _calculateDaysProgress(context: context, type: AchievementType.days12).progress, progressRemainder: null,
              ),
              const SizedBox(height: 10),
               _CListTile(
                title: "30 Days Trackd",
                subtitle: "Log 30 sessions",
                progressValue: _calculateDaysProgress(context: context, type: AchievementType.days30).progress,
              ),
              const SizedBox(height: 10),
               _CListTile(
                title: "75 Hard",
                subtitle: "Log 75 sessions",
                progressValue: _calculateDaysProgress(context: context, type: AchievementType.days75).progress,
              ),
              const SizedBox(height: 10),
               _CListTile(
                title: "100 Days Trackd",
                subtitle: "Log 100 sessions",
                progressValue: _calculateDaysProgress(context: context, type: AchievementType.days100).progress,
              ),
              const SizedBox(height: 10),
              const _CListTile(
                title: "Superset Specialist",
                subtitle: "Log 20 sessions with at least one superset",
                progressValue: 0.7,
              ),
              const SizedBox(height: 10),
              const _CListTile(
                title: "Stronger than ever",
                subtitle: "Log 10 sessions with a PB",
                progressValue: 0.1,
              ),
              const SizedBox(height: 10),
              const _CListTile(
                title: "One More Rep",
                subtitle: "Set a goal to increase the number of reps in a specific exercise",
                progressValue: 0.1,
              ),
              const SizedBox(height: 10),
              const _CListTile(
                title: "Time under tension",
                subtitle: "Set a goal to increase the duration in a specific exercise",
                progressValue: 0.2,
              ),
              const SizedBox(height: 10),
              const _CListTile(
                title: "Max Out Madness",
                subtitle: "Set a goal to increase the maximum weight lifted in a specific compound exercise",
                progressValue: 0.6,
              ),
              const SizedBox(height: 10),
              const _CListTile(
                title: "Obsessed",
                subtitle: "Log at least one session for 12 consecutive weeks",
                progressValue: 0.9,
              ),
              const SizedBox(height: 10),
              const _CListTile(
                title: "Never Skip a Monday",
                subtitle: "Log sessions for 12 consecutive mondays",
                progressValue: 0.3,
              ),
              const SizedBox(height: 10),
              const _CListTile(
                title: "Never Skip a Leg Day",
                subtitle: "Log sessions with at least one leg exercise for 12 consecutive weeks",
                progressValue: 0.6,
              ),
              const SizedBox(height: 10),
              const _CListTile(
                title: "Sweat Equity",
                subtitle: "Accumulate 20 hours of strength training",
                progressValue: 0.4,
              ),
              const SizedBox(height: 10),
              const _CListTile(
                title: "Weekend Warrior",
                subtitle: "Log a session on both Saturday and Sunday for four consecutive weeks",
                progressValue: 0.2,
              ),
              const SizedBox(height: 10),
              const _CListTile(
                title: "Bodyweight Champion",
                subtitle: "Complete a full-body workout using only bodyweight exercises for four consecutive weeks",
                progressValue: 0.1,
              ),
              const SizedBox(height: 10),
              const _CListTile(
                title: "Twice as strong",
                subtitle: "Achieve a 2x body weight deadlift",
                progressValue: 0.5,
              ),
              const SizedBox(height: 10),
              const _CListTile(
                title: "Twice as low",
                subtitle: "Achieve a 2x body weight squat",
                progressValue: 0.8,
              ),
            ]),
          ),
        ),
      )
    ]));
  }
}

class _CListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progressValue;
  final int progressRemainder;

  const _CListTile({required this.title, required this.subtitle, required this.progressValue, required this.progressRemainder});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(8),
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

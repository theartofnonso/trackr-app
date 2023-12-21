import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_constants.dart';
import '../widgets/backgrounds/gradient_background.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

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
              const _CListTile(
                title: "12 Days Trackd",
                subtitle: "Log at least 3 sessions per week for a month",
                value: 0.8,
              ),
              const SizedBox(height: 10),
              const _CListTile(
                title: "30 Days Trackd",
                subtitle: "Log 30 sessions",
                value: 0.5,
              ),
              const SizedBox(height: 10),
              const _CListTile(
                title: "75 Days Trackd",
                subtitle: "Log 75 sessions",
                value: 0.3,
              ),
              const SizedBox(height: 10),
              const _CListTile(
                title: "100 Days Trackd",
                subtitle: "Log 100 sessions",
                value: 0.1,
              ),
              const SizedBox(height: 10),
              const _CListTile(
                title: "Superset Specialist",
                subtitle: "Log 20 sessions with at least one superset",
                value: 0.7,
              ),
              const SizedBox(height: 10),
              const _CListTile(
                title: "Stronger than ever",
                subtitle: "Log 10 sessions with a PB",
                value: 0.1,
              ),
              const SizedBox(height: 10),
              const _CListTile(
                title: "One More Rep",
                subtitle: "Set a goal to increase the number of reps in a specific exercise",
                value: 0.1,
              ),
              const SizedBox(height: 10),
              const _CListTile(
                title: "Time under tension",
                subtitle: "Set a goal to increase the duration in a specific exercise",
                value: 0.2,
              ),
              const SizedBox(height: 10),
              const _CListTile(
                title: "Max Out Madness",
                subtitle: "Set a goal to increase the maximum weight lifted in a specific compound exercise",
                value: 0.6,
              ),
              const SizedBox(height: 10),
              const _CListTile(
                title: "Obsessed",
                subtitle: "Log at least one session for 12 consecutive weeks",
                value: 0.9,
              ),
              const SizedBox(height: 10),
              const _CListTile(
                title: "Never Skip a Monday",
                subtitle: "Log sessions for 12 consecutive mondays",
                value: 0.3,
              ),
              const SizedBox(height: 10),
              const _CListTile(
                title: "Never Skip a Leg Day",
                subtitle: "Log sessions with at least one leg exercise for 12 consecutive weeks",
                value: 0.6,
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
  final double value;

  const _CListTile({required this.title, required this.subtitle, required this.value});

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
                    value: value,
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    backgroundColor: tealBlueLighter,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text("3 days left", style: GoogleFonts.lato(color: Colors.white70, fontSize: 12)),
          ],
        ));
  }
}

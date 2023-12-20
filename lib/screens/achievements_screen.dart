import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_constants.dart';
import '../widgets/backgrounds/gradient_background.dart';
import 'achievement_screen.dart';

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
              const _CListTile(title: "12 Days Trackd", subtitle: "Log 3 sessions per week for 1 month", value: 0.8,),
              const SizedBox(height: 10),
              const _CListTile(title: "36 Days Trackd", subtitle: "Log 3 sessions per week for 3 months", value: 0.5,),
              const SizedBox(height: 10),
              const _CListTile(title: "72 Days Trackd", subtitle: "Log 3 sessions per week for 6 months", value: 0.3,),
              const SizedBox(height: 10),
              const _CListTile(title: "144 Days Trackd", subtitle: "Log 3 sessions per week for 1 year", value: 0.1,),
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
    final String assetName = 'assets/badge.svg';
    final Widget svg = SvgPicture.asset(
      assetName,
      width: 30,
      height: 30,
    );
    return Container(
        decoration: BoxDecoration(
          color: tealBlueLighter,
          borderRadius: BorderRadius.circular(5.0), // Set the border radius here
        ),
        child: ListTile(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AchievementScreen())),
            leading: svg,
            title: Text(title.toUpperCase(),
                style: GoogleFonts.lato(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: LinearProgressIndicator(
                    value: value,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    backgroundColor: tealBlueDark,
                  )),
                  const SizedBox(width: 12),
                  Text("3 days left", style: GoogleFonts.lato(color: Colors.white70, fontSize: 12)),
                ],
              ),
            )));
  }
}

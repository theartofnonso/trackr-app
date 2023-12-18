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
                  style: GoogleFonts.lato(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 20),
              const _CListTile(title: "25% Lift", subtitle: "Increase weight lifted by 25%", trailing: "4x"),
              const SizedBox(height: 10),
              const _CListTile(title: "50% Lift", subtitle: "Increase weight lifted by 50%", trailing: "2x"),
              const SizedBox(height: 10),
              const _CListTile(title: "75% Lift", subtitle: "Increase weight lifted by 75%", trailing: "0x"),
              const SizedBox(height: 10),
              const _CListTile(title: "20% Strong", subtitle: "Decrease assisted weight lifted by 20%", trailing: "0x"),
              const SizedBox(height: 10),
              const _CListTile(title: "50% Strong", subtitle: "Decrease assisted weight lifted by 50%", trailing: "0x"),
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
  final String trailing;

  const _CListTile({required this.title, required this.subtitle, required this.trailing});

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
          subtitle: Text(subtitle, style: GoogleFonts.lato(color: Colors.white70, fontSize: 14)),
          trailing:
              Text(trailing, style: GoogleFonts.lato(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
    );
  }
}

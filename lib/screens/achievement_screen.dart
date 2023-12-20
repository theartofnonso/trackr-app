import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_constants.dart';
import '../widgets/backgrounds/gradient_background.dart';

class AchievementScreen extends StatelessWidget {
  const AchievementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String assetName = 'assets/badge.svg';
    final Widget svg = SvgPicture.asset(
      assetName,
      width: 150,
      height: 150,
    );

    return Scaffold(
      body: Stack(children: [
        const Positioned.fill(child: GradientBackground()),
        Padding(
          padding: const EdgeInsets.only(right: 10.0, bottom: 10, left: 10),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_outlined),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ]),
                const SizedBox(height: 10),
                _AchievementTile(svg: svg, title: "12 Days TRACKd", subtitle: "Log 3 sessions per week for 1 month"),
                const SizedBox(height: 20),
                const _CListTile(
                  title: 'Leg Extension',
                  trailing: 'x5',
                ),
                const SizedBox(height: 8),
                _CListTile(
                  title: 'Bicep Curl',
                  trailing: 'x3',
                ),
                const SizedBox(height: 8),
                _CListTile(
                  title: 'Squat',
                  trailing: 'x1',
                ),
              ]),
            ),
          ),
        )
      ]),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const _AchievementTile({required this.svg, required this.title, required this.subtitle});

  final Widget svg;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      svg,
      const SizedBox(width: 10),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title.toUpperCase(),
              style: GoogleFonts.lato(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
          SizedBox(
              width: double.infinity,
              child: Text(subtitle,
                  style: GoogleFonts.lato(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600))),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 200, child: LinearProgressIndicator(value: 0.5)),
                const SizedBox(height: 4),
                Text("3 days left", style: GoogleFonts.lato(color: Colors.white70, fontSize: 16)),
              ],
            ),
          ),
        ]),
      ),
    ]);
  }
}

class _CListTile extends StatelessWidget {
  final String title;
  final String trailing;

  const _CListTile({required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: tealBlueLighter,
        borderRadius: BorderRadius.circular(5.0), // Set the border radius here
      ),
      child: ListTile(
          title: Text(title, style: GoogleFonts.lato(color: Colors.white, fontSize: 16)),
          subtitle: Text("5 personal bests since Tues 24 No 2023",
              style: GoogleFonts.lato(color: Colors.white70, fontSize: 15)),
          leading:
              Text(trailing, style: GoogleFonts.lato(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          trailing: const Icon(Icons.ios_share_rounded)),
    );
  }
}

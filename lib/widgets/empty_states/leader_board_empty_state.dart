import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/widgets/monitors/muscle_trend_monitor.dart';

import '../../colors.dart';

class LeaderBoardEmptyState extends StatelessWidget {
  const LeaderBoardEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
            leading: Stack(alignment: Alignment.center, children: [
              const FaIcon(FontAwesomeIcons.person, color: Colors.white70, size: 25),
              MuscleTrendMonitor(
                  value: 0,
                  width: 50,
                  height: 50,
                  strokeWidth: 4,
                  strokeCap: StrokeCap.round,
                  decoration: BoxDecoration(
                    color: sapphireDark.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(100),
                  ))
            ]),
            title: Text("Anon-1",
                style: GoogleFonts.ubuntu(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w700)),
            subtitle: Text("No data",
                style: GoogleFonts.ubuntu(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w400))),
        const SizedBox(height: 20),
        ListTile(
            leading: Stack(alignment: Alignment.center, children: [
              const FaIcon(FontAwesomeIcons.person, color: Colors.white70, size: 25),
              MuscleTrendMonitor(
                  value: 0,
                  width: 50,
                  height: 50,
                  strokeWidth: 4,
                  strokeCap: StrokeCap.round,
                  decoration: BoxDecoration(
                    color: sapphireDark.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(100),
                  ))
            ]),
            title: Text("Anon-1",
                style: GoogleFonts.ubuntu(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w700)),
            subtitle: Text("No data",
                style: GoogleFonts.ubuntu(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w400))),
      ],
    );
  }
}

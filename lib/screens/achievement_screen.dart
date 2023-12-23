import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/widgets/calendar_heatmap.dart';

import '../app_constants.dart';
import '../dtos/achievement_dto.dart';

class AchievementScreen extends StatefulWidget {
  final AchievementDto achievementDto;

  const AchievementScreen({super.key, required this.achievementDto});

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
        icon: const Icon(Icons.arrow_back_outlined),
        onPressed: () => Navigator.of(context).pop(),
      )),
      floatingActionButton: FloatingActionButton(
        heroTag: "fab_achievement_screen",
        onPressed: () {},
        backgroundColor: tealBlueLighter,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: const Icon(Icons.send_rounded, size: 28),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(right: 10.0, bottom: 10.0, left: 10.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.achievementDto.type.title, style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.w900)),
            Text(widget.achievementDto.type.description, style: GoogleFonts.lato(fontSize: 16, color: Colors.white70)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    minHeight: 8,
                    color: widget.achievementDto.progress.progressRemainder == 0 ? Colors.green : Colors.white,
                    value: widget.achievementDto.progress.progressValue,
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    backgroundColor: tealBlueLighter,
                  ),
                ),
                const SizedBox(width: 10),
                Text("${widget.achievementDto.progress.progressRemainder} left",
                    style: GoogleFonts.lato(color: Colors.white70, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 10),
            const CalendarHeatMap()
          ]),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/widgets/calendar_heatmap.dart';

import '../app_constants.dart';
import '../dtos/achievement_dto.dart';
import '../widgets/backgrounds/gradient_background.dart';

class AchievementScreen extends StatefulWidget {
  final AchievementDto achievementDto;

  const AchievementScreen({super.key, required this.achievementDto});

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
  @override
  Widget build(BuildContext context) {
    final monthsHeatMap = widget.achievementDto.progress.dates.values.map((dates) {
      return CalendarHeatMap(dates: dates, margin: const EdgeInsets.all(8), firstDate: dates.first);
    }).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: "fab_achievement_screen",
        onPressed: () {},
        backgroundColor: tealBlueLighter,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: const Icon(Icons.send_rounded, size: 28),
      ),
      body: Stack(children: [
        const Positioned.fill(child: GradientBackground()),
        SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0, bottom: 10.0, left: 10.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_outlined),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ]),
                const SizedBox(height: 10),
                Text(widget.achievementDto.type.title,
                    style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.w900)),
                Text(widget.achievementDto.type.description,
                    style: GoogleFonts.lato(fontSize: 16, color: Colors.white70)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5), border: Border.all(color: tealBlueLighter, width: 2.0)),
                  child: Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          minHeight: 8,
                          color: widget.achievementDto.progress.remainder == 0 ? Colors.green : Colors.white,
                          value: widget.achievementDto.progress.value,
                          borderRadius: const BorderRadius.all(Radius.circular(2)),
                          backgroundColor: tealBlueLighter,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text("${widget.achievementDto.progress.remainder} left",
                          style: GoogleFonts.lato(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                monthsHeatMap.length >= 3
                    ? Center(child: Wrap(children: monthsHeatMap))
                    : Wrap(children: monthsHeatMap),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                      color: tealBlue,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: tealBlueLighter, width: 2.0)),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const FaIcon(FontAwesomeIcons.lightbulb, size: 16),
                        const SizedBox(width: 6),
                        Text("Tips", style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w700)),
                      ]),
                      const SizedBox(height: 8),
                      Text(
                          "Embark on a fitness journey that fits seamlessly into your busy life. With our expertly designed program, training just three days a week is enough to see significant improvements in strength, endurance, and overall health",
                          style: GoogleFonts.lato(fontSize: 16)),
                    ],
                  ),
                )
              ]),
            ),
          ),
        )
      ]),
    );
  }
}

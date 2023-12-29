import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/widgets/calendar_heatmap.dart';

import '../app_constants.dart';
import '../dtos/achievement_dto.dart';
import '../widgets/backgrounds/gradient_background.dart';
import '../widgets/information_container.dart';
import '../widgets/information_container_lite.dart';

class AchievementScreen extends StatelessWidget {
  final AchievementDto achievementDto;

  const AchievementScreen({super.key, required this.achievementDto});

  @override
  Widget build(BuildContext context) {
    final monthsHeatMap = achievementDto.progress.dates.isNotEmpty
        ? achievementDto.progress.dates.values.map((dates) {
            return CalendarHeatMap(dates: dates, margin: const EdgeInsets.all(8));
          }).toList()
        : [const CalendarHeatMap(dates: [], margin: EdgeInsets.all(8))];

    return Scaffold(
      body: Stack(children: [
        const Positioned.fill(child: GradientBackground()),
        SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0, bottom: 10.0, left: 10.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ]),
                const SizedBox(height: 10),
                Text(achievementDto.type.title, style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.w900)),
                Text(achievementDto.type.description, style: GoogleFonts.lato(fontSize: 14, color: Colors.white70)),
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
                          color: achievementDto.progress.remainder == 0 ? Colors.green : Colors.white,
                          value: achievementDto.progress.value,
                          borderRadius: const BorderRadius.all(Radius.circular(2)),
                          backgroundColor: tealBlueLighter,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text("${achievementDto.progress.remainder} left",
                          style: GoogleFonts.lato(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                monthsHeatMap.length >= 3
                    ? Center(child: Wrap(children: monthsHeatMap))
                    : Wrap(children: monthsHeatMap),
                const SizedBox(height: 10),
                const InformationContainerLite(
                    content: 'Brightly-coloured squares represent days you logged a session for this achievement',
                    color: tealBlueLight),
                const SizedBox(height: 10),
                InformationContainer(
                    icon: const FaIcon(FontAwesomeIcons.lightbulb, size: 16),
                    title: 'Tip',
                    description: achievementDto.type.tip,
                    color: tealBlue),
              ]),
            ),
          ),
        )
      ]),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app_constants.dart';
import '../../dtos/achievement_dto.dart';
import '../calender_heatmaps/calendar_heatmap.dart';

class AchievementShare extends StatelessWidget {
  final GlobalKey globalKey;
  final AchievementDto achievementDto;
  final double? width;

  const AchievementShare({super.key, required this.globalKey, required this.achievementDto, this.width});

  @override
  Widget build(BuildContext context) {
    final completed = achievementDto.progress.remainder == 0;

    final monthsHeatMaps = achievementDto.progress.dates.isNotEmpty
        ? achievementDto.progress.dates.values.map((dates) {
            return CalendarHeatMap(dates: dates, initialDate: dates.first, spacing: 4);
          }).toList()
        : [CalendarHeatMap(dates: const [], initialDate: DateTime.now(), spacing: 4)];

    return RepaintBoundary(
        key: globalKey,
        child: Container(
            color: tealBlueDark,
            padding: const EdgeInsets.all(8),
            width: width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(achievementDto.type.title.toUpperCase(),
                    style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(completed ? achievementDto.type.completionMessage : achievementDto.type.description,
                    style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: monthsHeatMaps.length > 4 ? 4 : monthsHeatMaps.length,
                  childAspectRatio: 1,
                  mainAxisSpacing: 12.0,
                  crossAxisSpacing: 12.0,
                  children: List.generate(monthsHeatMaps.length, (index) => monthsHeatMaps[index]),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Image.asset(
                    'images/trackr.png',
                    fit: BoxFit.contain,
                    height: 8, // Adjust the height as needed
                  ),
                ),
              ],
            )));
  }
}

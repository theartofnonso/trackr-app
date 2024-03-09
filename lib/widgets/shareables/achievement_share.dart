import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../colors.dart';
import '../../dtos/achievement_dto.dart';

class AchievementShare extends StatelessWidget {
  final GlobalKey globalKey;
  final AchievementDto achievementDto;

  const AchievementShare({super.key, required this.globalKey, required this.achievementDto});

  @override
  Widget build(BuildContext context) {
    final completed = achievementDto.progress.remainder == 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: RepaintBoundary(
          key: globalKey,
          child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    sapphireDark80,
                    sapphireDark,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(achievementDto.type.title.toUpperCase(),
                      style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.w900),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 6),
                  Text(completed ? achievementDto.type.completionMessage : achievementDto.type.description,
                      style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center),
                ],
              )),
        ),
      ),
    );
  }
}

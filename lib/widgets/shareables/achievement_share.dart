import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../colors.dart';
import '../../dtos/achievement_dto.dart';

class AchievementShare extends StatelessWidget {
  final GlobalKey globalKey;
  final AchievementDto achievementDto;
  final double? width;

  const AchievementShare({super.key, required this.globalKey, required this.achievementDto, this.width});

  @override
  Widget build(BuildContext context) {
    final completed = achievementDto.progress.remainder == 0;

    return RepaintBoundary(
        key: globalKey,
        child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("From:", style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Image.asset(
                        'images/trackr.png',
                        fit: BoxFit.contain,
                        height: 8, // Adjust the height as needed
                      ),
                    )
                  ],
                ),
                const Divider(color: sapphireLighter, thickness: 2),
                Text(achievementDto.type.title.toUpperCase(),
                    style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(completed ? achievementDto.type.completionMessage : achievementDto.type.description,
                    style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w500)),
              ],
            )));
  }
}

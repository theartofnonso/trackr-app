import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app_constants.dart';
import '../../dtos/achievement_dto.dart';

class AchievementTile extends StatelessWidget {
  final AchievementDto achievement;
  final EdgeInsets margin;
  final void Function()? onTap;

  const AchievementTile({super.key, required this.achievement, required this.margin, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          padding: const EdgeInsets.all(8),
          margin: margin,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0), //
              border: Border.all(color: tealBlueLighter, width: 2) // Set the border radius here
              ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(achievement.type.title.toUpperCase(),
                            style: GoogleFonts.lato(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Text(achievement.type.description, style: GoogleFonts.lato(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      color: achievement.progress.remainder == 0 ? Colors.green : Colors.white,
                      value: achievement.progress.value,
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      backgroundColor: tealBlueLighter,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text("${achievement.progress.remainder} left",
                  style: GoogleFonts.lato(color: Colors.white70, fontSize: 12)),
            ],
          )),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../colors.dart';
import '../../dtos/achievement_dto.dart';

class AchievementTile extends StatelessWidget {
  final AchievementDto achievement;
  final EdgeInsets? margin;
  final void Function()? onTap;
  final Color? color;

  const AchievementTile({super.key, required this.achievement, this.margin, this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          margin: margin,
          decoration: BoxDecoration(
              color: sapphireDark.withOpacity(0.3),
              borderRadius: BorderRadius.circular(5.0), //
              //border: Border.all(color: sapphireLight, width: 2) // Set the border radius here
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
                            style:
                                GoogleFonts.montserrat(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Text(
                        achievement.progress.remainder == 0
                            ? achievement.type.completionMessage
                            : achievement.type.description,
                        style:
                            GoogleFonts.montserrat(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 10),
                    Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        LinearProgressIndicator(
                          minHeight: 18,
                          color: achievement.progress.remainder == 0 ? vibrantGreen : color,
                          value: achievement.progress.value,
                          borderRadius: const BorderRadius.all(Radius.circular(3)),
                          backgroundColor: sapphireDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}

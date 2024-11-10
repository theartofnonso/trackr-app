import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../colors.dart';
import '../../dtos/milestones/milestone_dto.dart';
import '../../screens/milestones/milestone_screen.dart';
import '../../utils/general_utils.dart';
import '../../utils/navigation_utils.dart';

class MilestoneGridItem extends StatelessWidget {
  final Milestone milestone;

  const MilestoneGridItem({super.key, required this.milestone});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        navigateWithSlideTransition(context: context, child: MilestoneScreen(milestone: milestone));
      },
      child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: sapphireDark80, borderRadius: BorderRadius.circular(5)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Image.asset(
              "challenges_icons/green_blob.png",
              fit: BoxFit.contain,
              height: 40, // Adjust the height as needed
            ),
            const SizedBox(height: 14),
            Text(
              milestone.name,
              style: GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            Text(
              milestone.caption,
              style: GoogleFonts.ubuntu(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white70),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: sapphireDark.withOpacity(0.3),
                borderRadius: BorderRadius.circular(5),
              ),
              child: LinearProgressIndicator(
                value: milestone.progress.$1,
                backgroundColor: sapphireDark,
                color: setsMilestoneColor(progress: milestone.progress.$1),
                minHeight: 16,
                borderRadius: BorderRadius.circular(3.0), // Border r
              ),
            )
          ])),
    );
  }
}
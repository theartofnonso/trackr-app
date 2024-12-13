import 'package:flutter/material.dart';

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

    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        navigateWithSlideTransition(context: context, child: MilestoneScreen(milestone: milestone));
      },
      child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: isDarkMode ? sapphireDark80 : Colors.grey.shade200, borderRadius: BorderRadius.circular(5)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Image.asset(
              "challenges_icons/green_blob.png",
              fit: BoxFit.contain,
              height: 40, // Adjust the height as needed
            ),
            const SizedBox(height: 14),
            Text(
              milestone.name,
              style: Theme.of(context).textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            Text(
              milestone.caption,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            const Spacer(),
            LinearProgressIndicator(
              value: milestone.progress.$1,
              backgroundColor: isDarkMode ? sapphireDark : Colors.grey.shade400,
              color: setsMilestoneColor(progress: milestone.progress.$1),
              minHeight: 20,
              borderRadius: BorderRadius.circular(3.0), // Border r
            )
          ])),
    );
  }
}

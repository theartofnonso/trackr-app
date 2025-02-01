import 'package:flutter/material.dart';

import '../../colors.dart';
import '../../dtos/milestones/milestone_dto.dart';
import '../../screens/milestones/milestone_screen.dart';
import '../../utils/general_utils.dart';
import '../../utils/navigation_utils.dart';

class MilestoneGridItem extends StatelessWidget {
  final Milestone milestone;
  final bool enabled;

  const MilestoneGridItem({super.key, required this.milestone, this.enabled = true});

  @override
  Widget build(BuildContext context) {

    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return GestureDetector(
      onTap: enabled ? () {
        navigateWithSlideTransition(context: context, child: MilestoneScreen(milestone: milestone));
      } : null,
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
              maxLines: 1,
            ),
            const SizedBox(height: 8),
            Text(
              milestone.caption,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.only(top: 10, right: 6, left: 8, bottom: 10),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.black12 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(5),
              ),
              child: LinearProgressIndicator(
                value: milestone.progress.$1,
                backgroundColor: isDarkMode ? sapphireDark : Colors.grey.shade400,
                color: setsMilestoneColor(progress: milestone.progress.$1),
                minHeight: 16,
                borderRadius: BorderRadius.circular(3.0), // Border r
              ),
            )
          ])),
    );
  }
}

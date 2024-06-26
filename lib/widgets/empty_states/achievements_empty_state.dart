import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/progress_dto.dart';
import 'package:tracker_app/enums/achievement_type_enums.dart';
import 'package:tracker_app/widgets/achievements/achievement_tile.dart';

import '../../dtos/achievement_dto.dart';

class AchievementsEmptyState extends StatelessWidget {
  const AchievementsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AchievementTile(
            achievement: AchievementDto(
                type: AchievementType.days75, progress: ProgressDto(value: 0.7, remainder: 4, dates: {})),
            color: Colors.white70),
        const SizedBox(height: 10),
        AchievementTile(
            achievement: AchievementDto(
                type: AchievementType.timeUnderTension, progress: ProgressDto(value: 0.2, remainder: 8, dates: {})),
            color: Colors.white70),
      ],
    );
  }
}

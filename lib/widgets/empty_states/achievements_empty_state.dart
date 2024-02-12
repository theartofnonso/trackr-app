import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/progress_dto.dart';
import 'package:tracker_app/enums/achievement_type_enums.dart';
import 'package:tracker_app/widgets/achievements/achievement_tile.dart';

import '../../dtos/achievement_dto.dart';
import '../backgrounds/gradient_widget.dart';

class AchievementsEmptyState extends StatelessWidget {

  const AchievementsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {

    const margin = EdgeInsets.only(bottom: 10);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GradientWidget(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AchievementTile(achievement: AchievementDto(type: AchievementType.days75, progress: ProgressDto(value: 0.7, remainder: 4, dates: {})), margin: margin, color: Colors.white54),
              AchievementTile(achievement: AchievementDto(type: AchievementType.timeUnderTension, progress: ProgressDto(value: 0.2, remainder: 8, dates: {})), margin: margin, color: Colors.white54),
            ],
          ),
        ),
      ],
    );
  }
}

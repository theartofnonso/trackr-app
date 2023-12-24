import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/progress_dto.dart';
import 'package:tracker_app/enums/achievement_type_enums.dart';
import 'package:tracker_app/widgets/achievements/achievement_tile.dart';
import 'package:tracker_app/widgets/empty_states/text_empty_state.dart';

import '../../app_constants.dart';
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
              AchievementTile(achievement: AchievementDto(type: AchievementType.days75, progress: ProgressDto(value: 0.5, remainder: 4, dates: {})), margin: margin),
              const Divider(thickness: 1.0, color: tealBlueLight),
              AchievementTile(achievement: AchievementDto(type: AchievementType.days75, progress: ProgressDto(value: 0.2, remainder: 8, dates: {})), margin: margin),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const TextEmptyState(message: "Start logging your sessions to achieve milestones and unlock badges."),
      ],
    );
  }
}

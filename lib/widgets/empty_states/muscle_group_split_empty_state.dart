import 'package:flutter/material.dart';
import 'package:tracker_app/widgets/backgrounds/gradient_widget.dart';

import '../../enums/muscle_group_enums.dart';
import '../chart/routine_muscle_group_split_chart.dart';

class MuscleGroupSplitEmptyState extends StatelessWidget {
  const MuscleGroupSplitEmptyState({super.key});

  @override
  Widget build(BuildContext context) {

    final muscleGroupFamilySplit = {
      MuscleGroupFamily.chest: 0.0,
      MuscleGroupFamily.back: 0.0,
      MuscleGroupFamily.legs: 0.0,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GradientWidget(
          child: RoutineMuscleGroupSplitChart(frequencyData: muscleGroupFamilySplit),
        )
      ],
    );
  }
}

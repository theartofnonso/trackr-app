import 'package:flutter/material.dart';
import 'package:tracker_app/widgets/backgrounds/gradient_widget.dart';
import 'package:tracker_app/widgets/chart/muscle_group_family_frequency_chart.dart';

import '../../enums/muscle_group_enums.dart';
import '../chart/muscle_group_family_chart.dart';

class MuscleGroupSplitFrequencyEmptyState extends StatelessWidget {
  const MuscleGroupSplitFrequencyEmptyState({super.key});

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
          child: MuscleGroupFamilyFrequencyChart(frequencyData: muscleGroupFamilySplit),
        )
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../dtos/appsync/routine_log_dto.dart';
import '../../enums/muscle_group_enums.dart';
import '../../utils/exercise_logs_utils.dart';
import '../../utils/string_utils.dart';
import '../chart/muscle_group_family_frequency_chart.dart';

class MuscleGroupFamilyFrequencyWidget extends StatefulWidget {
  final List<RoutineLogDto> logs;

  const MuscleGroupFamilyFrequencyWidget({super.key, required this.logs});

  @override
  State<MuscleGroupFamilyFrequencyWidget> createState() => _MuscleGroupFamilyFrequencyWidgetState();
}

class _MuscleGroupFamilyFrequencyWidgetState extends State<MuscleGroupFamilyFrequencyWidget> {
  bool _minimized = true;

  @override
  Widget build(BuildContext context) {
    final exerciseLogs = widget.logs
        .map((log) => loggedExercises(exerciseLogs: log.exerciseLogs))
        .expand((exerciseLogs) => exerciseLogs)
        .toList();

    final muscleGroupFamilyFrequencies = muscleGroupFamilyFrequencyOn4WeeksScale(exerciseLogs: exerciseLogs);

    final muscleGroupFamilies = muscleGroupFamilyFrequencies.keys.toSet();

    final listOfPopularMuscleGroupFamilies = MuscleGroupFamily.values.toSet();

    final untrainedMuscleGroups = listOfPopularMuscleGroupFamilies.difference(muscleGroupFamilies);

    String untrainedMuscleGroupsNames = joinWithAnd(items: untrainedMuscleGroups.map((muscle) => muscle.name).toList());

    if (untrainedMuscleGroups.length == MuscleGroupFamily.values.length) {
      untrainedMuscleGroupsNames = "any muscle groups";
    }

    return GestureDetector(
      onTap: _onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MuscleGroupSplitChart(
              title: "Muscle Groups Coverage",
              description:
                  "Train a variety of muscle groups to avoid muscle imbalances and prevent injury. On average each muscle group should be trained at least 2 times a week.",
              muscleGroupFamilyFrequencies: muscleGroupFamilyFrequencies,
              minimized: _minimized),
          if (untrainedMuscleGroups.isNotEmpty)
            RichText(
                text: TextSpan(text: "You have not trained", style: Theme.of(context).textTheme.bodySmall, children: [
              const TextSpan(text: " "),
              TextSpan(
                  text: untrainedMuscleGroupsNames,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
              const TextSpan(text: " "),
              TextSpan(text: "this month", style: Theme.of(context).textTheme.bodySmall),
            ])),
        ],
      ),
    );
  }

  void _onTap() {
    setState(() {
      _minimized = !_minimized;
    });
  }
}

class MuscleGroupSplitChart extends StatelessWidget {
  const MuscleGroupSplitChart(
      {super.key,
      required this.muscleGroupFamilyFrequencies,
      required bool minimized,
      required this.title,
      required this.description})
      : _minimized = minimized;

  final String title;
  final String description;
  final Map<MuscleGroupFamily, double> muscleGroupFamilyFrequencies;
  final bool _minimized;

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(title.toUpperCase(), style: Theme.of(context).textTheme.titleMedium),
        const Spacer(),
        if (muscleGroupFamilyFrequencies.length > 3)
          FaIcon(_minimized ? FontAwesomeIcons.angleDown : FontAwesomeIcons.angleUp, size: 16),
      ]),
      const SizedBox(height: 10),
      Text(description,
          style: isDarkMode
              ? Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)
              : Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black)),
      const SizedBox(height: 10),
      MuscleGroupFamilyFrequencyChart(frequencyData: muscleGroupFamilyFrequencies, minimized: _minimized),
    ]);
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../dtos/appsync/routine_log_dto.dart';
import '../../enums/muscle_group_enums.dart';
import '../../utils/exercise_logs_utils.dart';
import '../../utils/string_utils.dart';
import '../chart/muscle_group_frequency_chart.dart';

class MuscleGroupFrequencyWidget extends StatefulWidget {
  final List<RoutineLogDto> logs;

  const MuscleGroupFrequencyWidget({super.key, required this.logs});

  @override
  State<MuscleGroupFrequencyWidget> createState() => _MuscleGroupFrequencyWidgetState();
}

class _MuscleGroupFrequencyWidgetState extends State<MuscleGroupFrequencyWidget> {
  bool _minimized = true;

  @override
  Widget build(BuildContext context) {
    final exerciseLogs = widget.logs
        .map((log) => completedExercises(exerciseLogs: log.exerciseLogs))
        .expand((exerciseLogs) => exerciseLogs)
        .toList();

    final muscleGroupFrequencies = muscleGroupFrequencyOn4WeeksScale(exerciseLogs: exerciseLogs);

    final muscleGroupFrequencyKeys = muscleGroupFrequencies.keys.toSet();

    final untrainedMuscleGroups = MuscleGroup.values.toSet().difference(muscleGroupFrequencyKeys);

    String untrainedMuscleGroupsNames = joinWithAnd(items: untrainedMuscleGroups.map((muscle) => muscle.name).toList());

    if (untrainedMuscleGroups.length == MuscleGroup.values.length) {
      untrainedMuscleGroupsNames = "any muscle groups";
    }

    return GestureDetector(
      onTap: _onTap,
      child: Container(
        color: Colors.transparent,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text("Muscle Groups Frequency".toUpperCase(),
                style: GoogleFonts.ubuntu(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
            const Spacer(),
            if (muscleGroupFrequencies.length > 3)
              FaIcon(_minimized ? FontAwesomeIcons.angleDown : FontAwesomeIcons.angleUp,
                  color: Colors.white70, size: 16),
          ]),
          const SizedBox(height: 10),
          Text(
              "Train a variety of muscle groups to avoid muscle imbalances and prevent injury. On average each muscle group should be trained at least 2 times a week.",
              style: GoogleFonts.ubuntu(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          MuscleGroupFrequencyChart(frequencyData: muscleGroupFrequencies, minimized: _minimized),
          if (untrainedMuscleGroups.isNotEmpty)
            Column(
              children: [
                RichText(
                    text: TextSpan(
                        text: "You have not trained",
                        style: GoogleFonts.ubuntu(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                        children: [
                      const TextSpan(text: " "),
                      TextSpan(
                          text: untrainedMuscleGroupsNames,
                          style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                      const TextSpan(text: " "),
                      const TextSpan(
                          text: "this month",
                          style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                    ])),
              ],
            ),
        ]),
      ),
    );
  }

  void _onTap() {
    setState(() {
      _minimized = !_minimized;
    });
  }
}

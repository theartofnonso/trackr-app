import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../dtos/routine_log_dto.dart';
import '../../utils/exercise_logs_utils.dart';
import '../../utils/general_utils.dart';
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
        .map((log) => exerciseLogsWithCheckedSets(exerciseLogs: log.exerciseLogs))
        .expand((exerciseLogs) => exerciseLogs)
        .toList();

    final muscleGroupFamilyFrequencies = weeklyScaledMuscleGroupFamilyFrequency(exerciseLogs: exerciseLogs);

    final muscleGroupFamilies = muscleGroupFamilyFrequencies.keys.toSet();

    final listOfPopularMuscleGroupFamilies = popularMuscleGroupFamilies().toSet();

    final untrainedMuscleGroups = listOfPopularMuscleGroupFamilies.difference(muscleGroupFamilies);

    String untrainedMuscleGroupsNames = joinWithAnd(items: untrainedMuscleGroups.map((muscle) => muscle.name).toList());

    if(untrainedMuscleGroups.length == popularMuscleGroupFamilies().length) {
      untrainedMuscleGroupsNames = "any muscle groups";
    }

    return GestureDetector(
      onTap: _onTap,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text("Muscle Groups Frequency".toUpperCase(),
              style: GoogleFonts.ubuntu(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
          const Spacer(),
          if (muscleGroupFamilyFrequencies.length > 3)
            FaIcon(_minimized ? FontAwesomeIcons.angleDown : FontAwesomeIcons.angleUp, color: Colors.white70, size: 16),
        ]),
        const SizedBox(height: 10),
        Text(
            "Train a variety of muscle groups to avoid muscle imbalances and prevent injury. On average each muscle group should be trained at least 2 times a week.",
            style: GoogleFonts.ubuntu(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        MuscleGroupFamilyFrequencyChart(frequencyData: muscleGroupFamilyFrequencies, minimized: _minimized),
        if (untrainedMuscleGroups.isNotEmpty)
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
                const TextSpan(text: "this month", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
              ])),
      ]),
    );
  }

  void _onTap() {
    setState(() {
      _minimized = !_minimized;
    });
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/widgets/empty_states/muscle_group_split_frequency_empty_state.dart';

import '../../dtos/routine_log_dto.dart';
import '../../utils/exercise_logs_utils.dart';
import '../../utils/general_utils.dart';
import '../chart/muscle_group_family_frequency_chart.dart';

class MuscleGroupFamilyFrequencyWidget extends StatefulWidget {
  final List<RoutineLogDto> monthAndLogs;

  const MuscleGroupFamilyFrequencyWidget({super.key, required this.monthAndLogs});

  @override
  State<MuscleGroupFamilyFrequencyWidget> createState() => _MuscleGroupFamilyFrequencyWidgetState();
}

class _MuscleGroupFamilyFrequencyWidgetState extends State<MuscleGroupFamilyFrequencyWidget> {
  bool _minimized = true;

  @override
  Widget build(BuildContext context) {
    final exerciseLogs = widget.monthAndLogs
        .map((log) => exerciseLogsWithCheckedSets(exerciseLogs: log.exerciseLogs))
        .expand((exerciseLogs) => exerciseLogs)
        .toList();

    final muscleGroupFamilyFrequencies = scaledMuscleGroupFamilyFrequencies(exerciseLogs: exerciseLogs);

    final muscleGroupFamilies = muscleGroupFamilyFrequencies.keys;

    final untrainedMuscleGroups =
        popularMuscleGroupFamilies().where((family) => !muscleGroupFamilies.contains(family)).toList();

    String untrainedMuscleGroupsNames = "";

    if (untrainedMuscleGroups.isNotEmpty) {
      if (untrainedMuscleGroups.length > 1) {
        untrainedMuscleGroupsNames =
            "${untrainedMuscleGroups.take(untrainedMuscleGroups.length - 1).map((muscle) => muscle.name).join(", ")} and ${untrainedMuscleGroups.last.name}";
      } else {
        untrainedMuscleGroupsNames = untrainedMuscleGroups.first.name;
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text("Muscle Groups Frequency".toUpperCase(),
            style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
        const Spacer(),
        if (muscleGroupFamilyFrequencies.length > 3)
          GestureDetector(
              onTap: _onTap,
              child: FaIcon(_minimized ? FontAwesomeIcons.angleDown : FontAwesomeIcons.angleUp,
                  color: Colors.white70, size: 16)),
      ]),
      const SizedBox(height: 10),
      Text(
          "Train a variety of muscle groups to avoid muscle imbalances and prevent injury. On average each muscle group should be trained at least 2 times a week.",
          style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
      const SizedBox(height: 10),
      exerciseLogs.isNotEmpty
          ? MuscleGroupFamilyFrequencyChart(frequencyData: muscleGroupFamilyFrequencies, minimized: _minimized)
          : const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: MuscleGroupSplitFrequencyEmptyState(),
            ),
      if (untrainedMuscleGroups.isNotEmpty)
        RichText(
            text: TextSpan(
                text: "You have not trained",
                style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                children: [
              const TextSpan(text: " "),
              TextSpan(
                  text: untrainedMuscleGroupsNames,
                  style: GoogleFonts.montserrat(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            ])),
    ]);
  }

  void _onTap() {
    setState(() {
      _minimized = !_minimized;
    });
  }
}
